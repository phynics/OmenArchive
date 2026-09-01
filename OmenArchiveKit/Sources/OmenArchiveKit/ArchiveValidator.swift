import Foundation
import OmenURI
import Yams

public struct ArchiveValidationDiagnostic: Codable, Equatable, Sendable {
    public let relativePath: String
    public let message: String

    public init(relativePath: String, message: String) {
        self.relativePath = relativePath
        self.message = message
    }
}

public struct ArchiveValidationReport: Codable, Equatable, Sendable {
    public let filesValidated: Int
    public let diagnostics: [ArchiveValidationDiagnostic]
    public let mechanicsDiagnostics: [ArchiveMechanicsDiagnostic]

    public var isValid: Bool { diagnostics.isEmpty && mechanicsDiagnostics.isEmpty }

    public init(
        filesValidated: Int,
        diagnostics: [ArchiveValidationDiagnostic],
        mechanicsDiagnostics: [ArchiveMechanicsDiagnostic] = []
    ) {
        self.filesValidated = filesValidated
        self.diagnostics = diagnostics
        self.mechanicsDiagnostics = mechanicsDiagnostics
    }
}

/// Renders the complete validation report for host-facing diagnostics.
///
/// Structural and mechanics diagnostics intentionally share one formatter so
/// command-line, app, and other adapters cannot accidentally hide unresolved
/// mechanics or drift in their presentation of archive failures.
public enum ArchiveValidationDiagnosticFormatter {
    /// Returns one stable, human-readable line for every diagnostic in the
    /// report. Structural diagnostics precede mechanics diagnostics, matching
    /// the report's two explicit categories.
    public static func lines(for report: ArchiveValidationReport) -> [String] {
        let structural = report.diagnostics.map { diagnostic in
            "\(diagnostic.relativePath): \(diagnostic.message)"
        }
        let mechanics = report.mechanicsDiagnostics.map { diagnostic in
            "\(diagnostic.relativePath): mechanics [\(diagnostic.kind.rawValue)] \(diagnostic.message)"
        }
        return structural + mechanics
    }

    /// Returns the report's diagnostics separated by newlines.
    public static func format(_ report: ArchiveValidationReport) -> String {
        lines(for: report).joined(separator: "\n")
    }
}

public enum ArchiveValidationError: Error, Equatable, Sendable, CustomStringConvertible, LocalizedError {
    case invalidYAML(String)
    case invalidSchema(String)
    case invalidReference(String)
    case value(path: String, message: String)

    public var description: String {
        switch self {
        case .invalidYAML(let path): "YAML could not be parsed: \(path)"
        case .invalidSchema(let path): "Invalid schema document: \(path)"
        case .invalidReference(let reference): "Invalid schema reference: \(reference)"
        case .value(let path, let message): "Archive schema validation failed at \(path): \(message)."
        }
    }

    public var errorDescription: String? { description }
}

/// Validates authored archive files through the ArchiveFormat seam.
///
/// YAML parsing, JSON-schema references, common archive naming rules, and
/// diagnostics live here so browser, writer, importer, and CI adapters do not
/// each reproduce their own validation policy.
public struct ArchiveValidator {
    public let format: ArchiveFormat

    public init(format: ArchiveFormat) {
        self.format = format
    }

    public func validate(_ relativePath: String) throws {
        let text = try format.readUTF8(relativePath)
        try validate(text: text, relativePath: relativePath)
    }

    /// Validates editor text before it is written to disk.
    ///
    /// The path still comes from the archive manifest, so unsaved browser and
    /// writer content receives the same family, schema, naming, and custom
    /// archive rules as a file-backed validation.
    public func validate(text: String, relativePath: String) throws {
        try validate(text: text, relativePath: relativePath, includeMechanics: true)
    }

    private func validate(text: String, relativePath: String, includeMechanics: Bool) throws {
        let object = try parse(text: text, relativePath: relativePath)
        try validate(
            object: object,
            relativePath: relativePath,
            includeMechanics: includeMechanics
        )
    }

    private func validate(
        object: Any,
        relativePath: String,
        includeMechanics: Bool
    ) throws {
        let classification = try format.classify(relativePath)
        guard let schemaURL = format.schemaURL(for: classification) else {
            throw ArchiveValidationError.invalidSchema(classification.schema)
        }
        let schema = try loadSchema(at: schemaURL)
        try validate(object, schema: schema, schemaURL: schemaURL, path: "$")

        if case .publication = classification.kind,
           let publication = object as? [String: Any],
           let id = publication["id"] as? String,
           id != classification.publicationID {
            throw ArchiveValidationError.value(
                path: "$.id",
                message: "does not match publication directory \(classification.publicationID)"
            )
        }
        if case .resource = classification.kind {
            try validateArchiveRules(object: object, classification: classification)
        }
        guard includeMechanics, format.archiveRoot != nil else { return }
        let loader = ArchiveMechanicsLoader(format: format)
        let catalog = try loader.load()
        var mechanicsDiagnostics = catalog.validate().diagnostics
        mechanicsDiagnostics.append(contentsOf: try loader.publicationDependencyDiagnostics())
        if case .publication = classification.kind {
            let dependencies = try loader.publicationDependencies()[classification.publicationID] ?? []
            mechanicsDiagnostics.append(contentsOf: catalog.validate(
                publicationID: classification.publicationID, dependencies: dependencies
            ))
        } else if let normalized = normalizedObjectForMechanics(object) {
            mechanicsDiagnostics.append(contentsOf: catalog.validateRules(
                in: normalized, relativePath: relativePath
            ))
        }
        if let first = mechanicsDiagnostics.first {
            throw ArchiveValidationError.value(
                path: "$.mechanics",
                message: "[\(first.kind.rawValue)] \(first.message)"
            )
        }
    }

    public func validateAll() throws -> ArchiveValidationReport {
        let files = try format.files()
        var diagnostics: [ArchiveValidationDiagnostic] = []
        var mechanicsDiagnostics: [ArchiveMechanicsDiagnostic] = []
        let mechanicsCatalog = try ArchiveMechanicsLoader(format: format).load()
        mechanicsDiagnostics.append(contentsOf: mechanicsCatalog.validate().diagnostics)
        let mechanicsLoader = ArchiveMechanicsLoader(format: format)
        mechanicsDiagnostics.append(contentsOf: try mechanicsLoader.publicationDependencyDiagnostics())
        let publicationDependencies = try mechanicsLoader.publicationDependencies()
        for (publicationID, dependencies) in publicationDependencies {
            mechanicsDiagnostics.append(contentsOf: mechanicsCatalog.validate(
                publicationID: publicationID,
                dependencies: dependencies
            ))
        }
        for file in files {
            let text: String
            do {
                text = try format.readUTF8(file.relativePath)
            } catch {
                diagnostics.append(.init(relativePath: file.relativePath, message: String(describing: error)))
                continue
            }

            let object: Any
            do {
                object = try parse(text: text, relativePath: file.relativePath)
            } catch {
                diagnostics.append(.init(relativePath: file.relativePath, message: String(describing: error)))
                continue
            }

            do {
                try validate(
                    object: object,
                    relativePath: file.relativePath,
                    includeMechanics: false
                )
            } catch {
                diagnostics.append(.init(relativePath: file.relativePath, message: String(describing: error)))
            }

            if file.relativePath.hasSuffix(".yml"),
               let normalized = normalizedObjectForMechanics(object) {
                mechanicsDiagnostics.append(contentsOf: mechanicsCatalog.validateRules(
                    in: normalized,
                    relativePath: file.relativePath
                ))
            }
        }
        return ArchiveValidationReport(
            filesValidated: files.count,
            diagnostics: diagnostics.sorted {
                if $0.relativePath != $1.relativePath { return $0.relativePath < $1.relativePath }
                return $0.message < $1.message
            },
            mechanicsDiagnostics: mechanicsDiagnostics.sorted {
                if $0.relativePath != $1.relativePath { return $0.relativePath < $1.relativePath }
                if $0.kind != $1.kind { return $0.kind.rawValue < $1.kind.rawValue }
                if $0.moduleID != $1.moduleID { return ($0.moduleID ?? "") < ($1.moduleID ?? "") }
                return $0.message < $1.message
            }
        )
    }

    private func parse(text: String, relativePath: String) throws -> Any {
        let parsed: Any?
        do {
            parsed = try Yams.load(yaml: text)
        } catch {
            throw ArchiveValidationError.invalidYAML(relativePath)
        }
        return try normalizedObject(parsed, path: relativePath)
    }

    private func normalizedObjectForMechanics(_ value: Any?) -> Any? {
        guard let value else { return nil }
        if let dictionary = value as? [String: Any] {
            return dictionary.mapValues { normalizedObjectForMechanics($0) as Any }
        }
        if let dictionary = value as? [AnyHashable: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, item in
                guard let key = item.key as? String else { return }
                result[key] = normalizedObjectForMechanics(item.value)
            }
        }
        if let array = value as? [Any] {
            return array.compactMap(normalizedObjectForMechanics)
        }
        return value
    }

    private func validateArchiveRules(
        object: Any,
        classification: ArchivePathClassification
    ) throws {
        guard let resource = object as? [String: Any] else {
            throw ArchiveValidationError.value(path: "$", message: "must be an object")
        }

        var errors: [(path: String, message: String)] = []
        func record(_ path: String, _ message: String) {
            errors.append((path: path, message: message))
        }

        if let source = resource["source"] as? [String: Any],
           let book = source["book"] as? String {
            if book.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                record("$.source.book", "is required")
            }
        }

        if let name = resource["name"] as? String {
            if name != name.lowercased() {
                record("$.name", "must be lowercase")
            }
            let basename = URL(fileURLWithPath: classification.relativePath)
                .deletingPathExtension()
                .lastPathComponent
            if !acceptedSlugs(for: name, classification: classification).contains(basename) {
                record("$.name", "filename slug \(basename) does not match name slug")
            }
        }

        if case .resource(let familyID) = classification.kind,
           familyID == "heritage",
           classification.resourceParts.count == 2,
           let ancestry = resource["ancestry"] as? String,
           ancestry != classification.resourceParts[0] {
            record(
                "$.ancestry",
                "heritage ancestry \(ancestry) does not match directory \(classification.resourceParts[0])"
            )
        }

        if case .resource(let familyID) = classification.kind,
           familyID == "background",
           let variants = resource["variants"] as? [Any] {
            var keys: [String] = []
            for variant in variants {
                if let variant = variant as? [String: Any], let key = variant["key"] as? String {
                    keys.append(key)
                }
            }
            let duplicates = Dictionary(grouping: keys, by: { $0 })
                .filter { $1.count > 1 }
                .keys
                .sorted()
            for duplicate in duplicates {
                record("$.variants", "background variant key \(duplicate) is duplicated")
            }
        }

        guard !errors.isEmpty else { return }
        if errors.count == 1, let error = errors.first {
            throw ArchiveValidationError.value(path: error.path, message: error.message)
        }
        let message = errors
            .map { "\($0.path): \($0.message)" }
            .joined(separator: "; ")
        throw ArchiveValidationError.value(path: "$", message: message)
    }

    private func acceptedSlugs(
        for name: String,
        classification: ArchivePathClassification
    ) -> [String] {
        var result = format.expectedSlugs(for: name, classification: classification)
        guard case .resource(let familyID) = classification.kind,
              familyID == "class",
              classification.resourceParts.count == 3 else {
            return result
        }

        let section = classification.resourceParts[1]
        let basename = URL(fileURLWithPath: classification.relativePath)
            .deletingPathExtension()
            .lastPathComponent
        let classSlug = classification.resourceParts[0]

        if section == "features",
           let range = basename.range(of: "^\\d+-", options: .regularExpression) {
            let prefix = String(basename[range])
            for slug in result {
                result.append(prefix + slug)
                result.append(prefix + slug + "-(\(classSlug))")
            }
        }
        if section == "schools" {
            result.append(contentsOf: result.map { $0.replacingOccurrences(of: "school-of-", with: "") })
            result.append(contentsOf: result.map { $0.replacingOccurrences(of: "school-of-the-", with: "") })
        }
        if ["basic-lessons", "greater-lessons", "major-lessons"].contains(section) {
            result.append(contentsOf: result.map { $0.replacingOccurrences(of: "lesson-of-the-", with: "") })
            result.append(contentsOf: result.map { $0.replacingOccurrences(of: "lesson-of-", with: "") })
        }
        return result.reduce(into: []) { values, candidate in
            if !values.contains(candidate) { values.append(candidate) }
        }
    }

    private func normalizedObject(_ value: Any?, path: String) throws -> Any {
        guard let value else { throw ArchiveValidationError.invalidYAML(path) }
        if let dictionary = value as? [String: Any] {
            return try dictionary.mapValues { try normalizedObject($0, path: path) }
        }
        if let dictionary = value as? [AnyHashable: Any] {
            var normalized: [String: Any] = [:]
            for (key, value) in dictionary {
                guard let key = key as? String else {
                    throw ArchiveValidationError.invalidYAML(path)
                }
                normalized[key] = try normalizedObject(value, path: path)
            }
            return normalized
        }
        if let array = value as? [Any] {
            return try array.map { try normalizedObject($0, path: path) }
        }
        return value
    }

    private func loadSchema(at url: URL) throws -> [String: Any] {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ArchiveValidationError.invalidSchema(url.path)
        }
        guard let schema = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ArchiveValidationError.invalidSchema(url.path)
        }
        return schema
    }

    private func validate(
        _ instance: Any,
        schema: [String: Any],
        schemaURL: URL,
        path: String
    ) throws {
        if let reference = schema["$ref"] as? String {
            let resolved = try resolve(reference, from: schemaURL)
            try validate(instance, schema: resolved.schema, schemaURL: resolved.url, path: path)
            return
        }

        if let type = schema["type"] as? String {
            try validateType(type, instance: instance, path: path)
        }
        if let values = schema["enum"] as? [Any], !values.contains(where: { schemaValuesEqual($0, instance) }) {
            throw ArchiveValidationError.value(path: path, message: "is not an allowed value")
        }
        if let constant = schema["const"], !schemaValuesEqual(constant, instance) {
            throw ArchiveValidationError.value(path: path, message: "does not match the required value")
        }
        if let minimum = schema["minimum"] as? NSNumber,
           let number = instance as? NSNumber,
           !isBoolean(number), number.doubleValue < minimum.doubleValue {
            throw ArchiveValidationError.value(path: path, message: "is less than minimum \(minimum)")
        }
        if let maximum = schema["maximum"] as? NSNumber,
           let number = instance as? NSNumber,
           !isBoolean(number), number.doubleValue > maximum.doubleValue {
            throw ArchiveValidationError.value(path: path, message: "is greater than maximum \(maximum)")
        }

        if let allOf = schema["allOf"] as? [[String: Any]] {
            for part in allOf { try validate(instance, schema: part, schemaURL: schemaURL, path: path) }
        }
        if let oneOf = schema["oneOf"] as? [[String: Any]] {
            var matches = 0
            var failures: [String] = []
            for option in oneOf {
                do {
                    try validate(instance, schema: option, schemaURL: schemaURL, path: path)
                    matches += 1
                } catch {
                    failures.append(String(describing: error))
                }
            }
            guard matches == 1 else {
                let detail = failures.isEmpty ? "" : "; " + failures.joined(separator: "; ")
                throw ArchiveValidationError.value(
                    path: path,
                    message: "must match exactly one schema option\(detail)"
                )
            }
        }
        if let anyOf = schema["anyOf"] as? [[String: Any]] {
            guard anyOf.contains(where: { (try? validate(instance, schema: $0, schemaURL: schemaURL, path: path)) != nil }) else {
                throw ArchiveValidationError.value(path: path, message: "must match one schema option")
            }
        }

        if let array = instance as? [Any] {
            if let minimum = schema["minItems"] as? Int, array.count < minimum {
                throw ArchiveValidationError.value(path: path, message: "has fewer than \(minimum) items")
            }
            if let itemSchema = schema["items"] as? [String: Any] {
                for (index, value) in array.enumerated() {
                    try validate(value, schema: itemSchema, schemaURL: schemaURL, path: "\(path)[\(index)]")
                }
            }
        }

        guard let object = instance as? [String: Any] else { return }
        if let minimum = schema["minProperties"] as? Int, object.count < minimum {
            throw ArchiveValidationError.value(path: path, message: "has fewer than \(minimum) properties")
        }
        if let maximum = schema["maxProperties"] as? Int, object.count > maximum {
            throw ArchiveValidationError.value(path: path, message: "has more than \(maximum) properties")
        }
        if let required = schema["required"] as? [String] {
            for key in required where object[key] == nil {
                throw ArchiveValidationError.value(path: "\(path).\(key)", message: "is required")
            }
        }

        let properties = schema["properties"] as? [String: [String: Any]] ?? [:]
        for (key, propertySchema) in properties where object[key] != nil {
            try validate(object[key] as Any, schema: propertySchema, schemaURL: schemaURL, path: "\(path).\(key)")
        }
        let patterns = schema["patternProperties"] as? [String: [String: Any]] ?? [:]
        for (pattern, propertySchema) in patterns {
            let regex = try NSRegularExpression(pattern: pattern)
            for (key, value) in object where regex.firstMatch(in: key, range: NSRange(key.startIndex..., in: key)) != nil {
                try validate(value, schema: propertySchema, schemaURL: schemaURL, path: "\(path).\(key)")
            }
        }
        if let additional = schema["additionalProperties"] as? Bool, !additional {
            for key in object.keys where properties[key] == nil && !matchesAnyPattern(key, patterns: patterns) {
                throw ArchiveValidationError.value(path: "\(path).\(key)", message: "is not allowed by schema")
            }
        }
    }

    private func validateType(_ type: String, instance: Any, path: String) throws {
        let valid: Bool
        switch type {
        case "array": valid = instance is [Any]
        case "boolean": valid = instance is Bool
        case "integer":
            valid = (instance as? NSNumber).map { !isBoolean($0) && $0.doubleValue.rounded() == $0.doubleValue } ?? false
        case "number": valid = (instance as? NSNumber).map { !isBoolean($0) } ?? false
        case "object": valid = instance is [String: Any]
        case "string": valid = instance is String
        default: valid = true
        }
        guard valid else {
            throw ArchiveValidationError.value(path: path, message: "must be \(type)")
        }
    }

    private func resolve(_ reference: String, from schemaURL: URL) throws -> (schema: [String: Any], url: URL) {
        let parts = reference.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let targetURL = parts[0].isEmpty
            ? schemaURL
            : schemaURL.deletingLastPathComponent().appendingPathComponent(String(parts[0])).standardizedFileURL
        guard let archiveRoot = format.archiveRoot else {
            throw ArchiveValidationError.invalidReference(reference)
        }
        let schemaRoot = archiveRoot.appendingPathComponent("schemas", isDirectory: true).standardizedFileURL
        guard targetURL.path == schemaRoot.path || targetURL.path.hasPrefix(schemaRoot.path + "/") else {
            throw ArchiveValidationError.invalidReference(reference)
        }
        let schema = try loadSchema(at: targetURL)
        guard parts.count == 2 else { return (schema, targetURL) }
        guard let target = pointer(String(parts[1]), in: schema) as? [String: Any] else {
            throw ArchiveValidationError.invalidReference(reference)
        }
        return (target, targetURL)
    }

    private func pointer(_ fragment: String, in schema: [String: Any]) -> Any? {
        let trimmed = fragment.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !trimmed.isEmpty else { return schema }
        return trimmed.split(separator: "/").reduce(schema as Any?) { value, part in
            guard let dictionary = value as? [String: Any] else { return nil }
            let key = part.replacingOccurrences(of: "~1", with: "/").replacingOccurrences(of: "~0", with: "~")
            return dictionary[key]
        }
    }

    private func schemaValuesEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        switch (lhs, rhs) {
        case let (left as String, right as String): left == right
        case let (left as Bool, right as Bool): left == right
        case let (left as NSNumber, right as NSNumber): !isBoolean(left) && !isBoolean(right) && left == right
        default: false
        }
    }

    private func matchesAnyPattern(_ key: String, patterns: [String: [String: Any]]) -> Bool {
        patterns.keys.contains { pattern in
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
            return regex.firstMatch(in: key, range: NSRange(key.startIndex..., in: key)) != nil
        }
    }

    private func isBoolean(_ number: NSNumber) -> Bool {
        CFGetTypeID(number) == CFBooleanGetTypeID()
    }
}
