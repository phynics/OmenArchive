import Foundation
import OmenMechanics
import OmenURI
import Yams

/// One mechanics descriptor discovered in an archive.
public struct ArchiveMechanicsDocument: Equatable, Sendable {
    public let relativePath: String
    public let rawData: Data
    public let descriptor: MechanicsModuleDescriptor?
    public let decodingError: String?

    public init(
        relativePath: String,
        rawData: Data,
        descriptor: MechanicsModuleDescriptor?,
        decodingError: String? = nil
    ) {
        self.relativePath = relativePath
        self.rawData = rawData
        self.descriptor = descriptor
        self.decodingError = decodingError
    }
}

public enum ArchiveMechanicsDiagnosticKind: String, Codable, Equatable, Hashable, Sendable {
    case malformedDescriptor
    case invalidDescriptor
    case duplicateModule
    case unresolvedDependency
    case dependencyRevisionMismatch
    case contractCollision
    case unknownEffect
    case effectRevisionMismatch
    case missingInput
    case unexpectedInput
    case inputTypeMismatch
    case invalidLiteral
    case invalidSelection
    case pathIdentityMismatch
    case malformedDependency
}

/// A structured mechanics contract issue. Diagnostics never discard the source
/// document, which lets editors report problems without losing authored data.
public struct ArchiveMechanicsDiagnostic: Codable, Equatable, Hashable, Sendable {
    public let relativePath: String
    public let moduleID: String?
    public let kind: ArchiveMechanicsDiagnosticKind
    public let message: String

    public init(
        relativePath: String,
        moduleID: String? = nil,
        kind: ArchiveMechanicsDiagnosticKind,
        message: String
    ) {
        self.relativePath = relativePath
        self.moduleID = moduleID
        self.kind = kind
        self.message = message
    }
}

public struct ArchiveMechanicsValidationReport: Codable, Equatable, Sendable {
    public let documentsValidated: Int
    public let diagnostics: [ArchiveMechanicsDiagnostic]

    public var isValid: Bool { diagnostics.isEmpty }

    public init(documentsValidated: Int, diagnostics: [ArchiveMechanicsDiagnostic]) {
        self.documentsValidated = documentsValidated
        self.diagnostics = diagnostics
    }
}

/// The merged, archive-visible mechanics contract.
public struct ArchiveMechanicsCatalog: Sendable {
    public let documents: [ArchiveMechanicsDocument]

    public var descriptors: [MechanicsModuleDescriptor] {
        documents.compactMap(\.descriptor)
    }

    public init(documents: [ArchiveMechanicsDocument]) {
        self.documents = documents.sorted { $0.relativePath < $1.relativePath }
    }

    public func descriptor(for moduleID: MechanicsModuleID) -> MechanicsModuleDescriptor? {
        descriptors.first { $0.moduleID == moduleID }
    }

    /// Validates all documents as one merged contract. Unknown dependencies are
    /// reported while all successfully decoded descriptors remain available.
    public func validate() -> ArchiveMechanicsValidationReport {
        var diagnostics: [ArchiveMechanicsDiagnostic] = []
        var byModuleID: [MechanicsModuleID: ArchiveMechanicsDocument] = [:]

        for document in documents {
            guard let descriptor = document.descriptor else {
                diagnostics.append(.init(
                    relativePath: document.relativePath,
                    kind: .malformedDescriptor,
                    message: document.decodingError ?? "Descriptor could not be decoded."
                ))
                continue
            }
            if byModuleID.updateValue(document, forKey: descriptor.moduleID) != nil {
                diagnostics.append(.init(
                    relativePath: document.relativePath,
                    moduleID: descriptor.moduleID.description,
                    kind: .duplicateModule,
                    message: "Module is declared more than once."
                ))
            }
        }

        let descriptors = descriptors
        for document in documents {
            guard let descriptor = document.descriptor else { continue }
            let dependenciesResolved = descriptor.dependencies.allSatisfy {
                byModuleID[$0.moduleID]?.descriptor != nil
            }
            if dependenciesResolved {
                do {
                    try DescriptorValidation.validate(descriptor, against: descriptors)
                } catch {
                    diagnostics.append(.init(
                        relativePath: document.relativePath,
                        moduleID: descriptor.moduleID.description,
                        kind: .invalidDescriptor,
                        message: String(describing: error)
                    ))
                }
            }
            let actualFilename = URL(fileURLWithPath: document.relativePath).lastPathComponent
            let expectedFilename = descriptor.moduleID.rawValue + ".json"
            if actualFilename != expectedFilename {
                diagnostics.append(.init(
                    relativePath: document.relativePath,
                    moduleID: descriptor.moduleID.description,
                    kind: .pathIdentityMismatch,
                    message: "Descriptor filename must be \(expectedFilename)."
                ))
            }
            for dependency in descriptor.dependencies {
                guard let target = byModuleID[dependency.moduleID]?.descriptor else {
                    diagnostics.append(.init(
                        relativePath: document.relativePath,
                        moduleID: descriptor.moduleID.description,
                        kind: .unresolvedDependency,
                        message: "Module \(descriptor.moduleID) requires unresolved module \(dependency.moduleID)."
                    ))
                    continue
                }
                guard target.revision >= dependency.revision else {
                    diagnostics.append(.init(
                        relativePath: document.relativePath,
                        moduleID: descriptor.moduleID.description,
                        kind: .dependencyRevisionMismatch,
                        message: "Module \(descriptor.moduleID) requires \(dependency.moduleID) revision \(dependency.revision), found \(target.revision)."
                    ))
                    continue
                }
            }
        }

        if diagnostics.isEmpty {
            do {
                try DescriptorValidation.validate(descriptors)
            } catch {
                diagnostics.append(.init(
                    relativePath: "mechanics",
                    kind: .contractCollision,
                    message: String(describing: error)
                ))
            }
        }

        return ArchiveMechanicsValidationReport(
            documentsValidated: documents.count,
            diagnostics: diagnostics.sorted {
                if $0.relativePath != $1.relativePath { return $0.relativePath < $1.relativePath }
                return $0.message < $1.message
            }
        )
    }

    /// Validates one publication's declared module dependencies against this
    /// catalog. The raw publication object is intentionally left untouched.
    public func validate(publicationID: String, dependencies: [MechanicsModuleDependency]) -> [ArchiveMechanicsDiagnostic] {
        var known: [MechanicsModuleID: MechanicsModuleDescriptor] = [:]
        for descriptor in descriptors where known[descriptor.moduleID] == nil {
            known[descriptor.moduleID] = descriptor
        }
        return dependencies.compactMap { dependency in
            guard let descriptor = known[dependency.moduleID] else {
                return .init(
                    relativePath: "src/\(publicationID)/publication.yml",
                    moduleID: dependency.moduleID.description,
                    kind: .unresolvedDependency,
                    message: "Publication \(publicationID) requires unresolved module \(dependency.moduleID)."
                )
            }
            guard descriptor.revision >= dependency.revision else {
                return .init(
                    relativePath: "src/\(publicationID)/publication.yml",
                    moduleID: dependency.moduleID.description,
                    kind: .dependencyRevisionMismatch,
                    message: "Publication \(publicationID) requires \(dependency.moduleID) revision \(dependency.revision), found \(descriptor.revision)."
                )
            }
            return nil
        }
    }

    /// Validates canonical effect rules embedded in an authored resource.
    /// Canonical effect rules are checked against the merged mechanics descriptors.
    public func validateRules(in value: Any, relativePath: String) -> [ArchiveMechanicsDiagnostic] {
        var diagnostics: [ArchiveMechanicsDiagnostic] = []
        walkRules(value, relativePath: relativePath, diagnostics: &diagnostics)
        return diagnostics
    }

    private func walkRules(
        _ value: Any,
        relativePath: String,
        diagnostics: inout [ArchiveMechanicsDiagnostic]
    ) {
        if let mapping = value as? [String: Any] {
            if let rules = mapping["rules"] as? [Any] {
                for rule in rules {
                    validateRule(rule, relativePath: relativePath, diagnostics: &diagnostics)
                }
            }
            for child in mapping.values {
                walkRules(child, relativePath: relativePath, diagnostics: &diagnostics)
            }
        } else if let mapping = value as? [AnyHashable: Any] {
            for child in mapping.values {
                walkRules(child, relativePath: relativePath, diagnostics: &diagnostics)
            }
        } else if let array = value as? [Any] {
            for child in array {
                walkRules(child, relativePath: relativePath, diagnostics: &diagnostics)
            }
        }
    }

    private func validateRule(
        _ value: Any,
        relativePath: String,
        diagnostics: inout [ArchiveMechanicsDiagnostic]
    ) {
        guard let rule = value as? [String: Any] else { return }
        if rule["effectTemplate"] != nil {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .unknownEffect,
                message: "effectTemplate is no longer supported; use effectReference and inputRecipes."
            ))
            return
        }
        let referenceValue: Any?
        let recipesValue: Any?
        if let reference = rule["effectReference"] as? [String: Any] {
            referenceValue = reference
            recipesValue = rule["inputRecipes"]
        } else if rule["effect"] != nil {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .unknownEffect,
                message: "Nested effect references are not supported; use the flat effectReference wire shape."
            ))
            return
        } else {
            return
        }

        guard let referenceValue,
              let referenceData = try? JSONSerialization.data(withJSONObject: referenceValue),
              let reference = try? JSONDecoder().decode(EffectReference.self, from: referenceData) else {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .unknownEffect,
                message: "Canonical effect reference could not be decoded."
            ))
            return
        }
        let candidates = descriptors.flatMap { descriptor in
            descriptor.effects.filter { $0.reference.kindID == reference.kindID }
        }
        guard let effect = candidates.first else {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .unknownEffect,
                message: "Effect \(reference.kindID) is not declared by a discovered mechanics module."
            ))
            return
        }
        guard effect.reference.revision == reference.revision else {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .effectRevisionMismatch,
                message: "Effect \(reference.kindID) requires revision \(effect.reference.revision), found \(reference.revision)."
            ))
            return
        }
        guard let recipes = recipesValue as? [Any] else {
            if !effect.inputDescriptors.isEmpty {
                diagnostics.append(.init(
                    relativePath: relativePath,
                    kind: .missingInput,
                    message: "Effect \(reference.kindID) requires \(effect.inputDescriptors.count) ordered input recipes."
                ))
            }
            return
        }

        let expected = effect.inputDescriptors
        let actual = recipes.compactMap { $0 as? [String: Any] }
        guard actual.count == recipes.count else {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .inputTypeMismatch,
                message: "Effect \(reference.kindID) contains a malformed input recipe."
            ))
            return
        }
        if actual.count < expected.count {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .missingInput,
                message: "Effect \(reference.kindID) is missing ordered input recipes."
            ))
        } else if actual.count > expected.count {
            diagnostics.append(.init(
                relativePath: relativePath,
                kind: .unexpectedInput,
                message: "Effect \(reference.kindID) contains unexpected input recipes."
            ))
        }

        var schemaByID: [ValueTypeID: ValueSchema] = [:]
        var revisionByID: [ValueTypeID: Int] = [:]
        for valueType in descriptors.flatMap(\.valueTypes) where schemaByID[valueType.typeID] == nil {
            schemaByID[valueType.typeID] = valueType.schema
            revisionByID[valueType.typeID] = valueType.revision
        }
        for (index, descriptor) in expected.enumerated() where index < actual.count {
            let recipe = actual[index]
            guard recipe["inputName"] as? String == descriptor.name else {
                diagnostics.append(.init(
                    relativePath: relativePath,
                    kind: .inputTypeMismatch,
                    message: "Effect \(reference.kindID) input \(index) must be named \(descriptor.name) in authored order."
                ))
                continue
            }
            guard let expectedValue = recipe["expectedValue"] as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: expectedValue),
                  let decoded = try? JSONDecoder().decode(ExpectedValue.self, from: data) else {
                diagnostics.append(.init(
                    relativePath: relativePath,
                    kind: .inputTypeMismatch,
                    message: "Effect \(reference.kindID) input \(descriptor.name) has an invalid expected value."
                ))
                continue
            }
            guard decoded.valueTypeID == descriptor.valueTypeID else {
                diagnostics.append(.init(
                    relativePath: relativePath,
                    kind: .inputTypeMismatch,
                    message: "Effect \(reference.kindID) input \(descriptor.name) expects \(descriptor.valueTypeID), found \(decoded.valueTypeID)."
                ))
                continue
            }
            validateExpectedValue(decoded, schemaByID: schemaByID, revisionByID: revisionByID, relativePath: relativePath, effect: reference, inputName: descriptor.name, diagnostics: &diagnostics)
        }
    }

    private func validateExpectedValue(
        _ expected: ExpectedValue,
        schemaByID: [ValueTypeID: ValueSchema],
        revisionByID: [ValueTypeID: Int],
        relativePath: String,
        effect: EffectReference,
        inputName: String,
        diagnostics: inout [ArchiveMechanicsDiagnostic]
    ) {
        guard let schema = schemaByID[expected.valueTypeID] else {
            diagnostics.append(.init(relativePath: relativePath, kind: .inputTypeMismatch, message: "Input \(inputName) references an unavailable value type \(expected.valueTypeID)."))
            return
        }
        switch expected.source {
        case .literal(let value):
            guard value.typeID == expected.valueTypeID,
                  value.revision == (revisionByID[expected.valueTypeID] ?? -1),
                  (try? schema.validate(value.payload)) != nil else {
                diagnostics.append(.init(relativePath: relativePath, kind: .invalidLiteral, message: "Effect \(effect.kindID) input \(inputName) contains a literal outside its registered value schema."))
                return
            }
        case .selection(let selection):
            guard selection.valueTypeID == expected.valueTypeID else {
                diagnostics.append(.init(relativePath: relativePath, kind: .invalidSelection, message: "Effect \(effect.kindID) input \(inputName) selection type does not match its expected value type."))
                return
            }
            if case .explicit(let values) = selection.options {
                for value in values where value.typeID != selection.valueTypeID || value.revision != (revisionByID[selection.valueTypeID] ?? -1) || (try? schema.validate(value.payload)) == nil {
                    diagnostics.append(.init(relativePath: relativePath, kind: .invalidSelection, message: "Effect \(effect.kindID) input \(inputName) contains a selection option outside its registered value schema."))
                    break
                }
            }
        case .lookupByID, .lookupByName:
            break
        }
    }
}

/// Discovers and loads root mechanics descriptors.
public struct ArchiveMechanicsLoader: Sendable {
    public static let directoryName = "mechanics"

    public let format: ArchiveFormat

    public init(format: ArchiveFormat) {
        self.format = format
    }

    public func discover() throws -> [ArchiveMechanicsDocument] {
        guard let root = format.archiveRoot else { return [] }
        let mechanicsRoot = root.appendingPathComponent(Self.directoryName, isDirectory: true)
        guard FileManager.default.fileExists(atPath: mechanicsRoot.path) else { return [] }
        let rootValues = try mechanicsRoot.resourceValues(forKeys: [.isSymbolicLinkKey, .isDirectoryKey])
        if rootValues.isSymbolicLink == true {
            throw ArchiveFormatError.symlinkPath(Self.directoryName)
        }
        guard rootValues.isDirectory == true else {
            throw ArchiveFormatError.unsupportedPath(Self.directoryName)
        }
        let entries = try FileManager.default.contentsOfDirectory(
            at: mechanicsRoot,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: []
        )
        for entry in entries {
            let values = try entry.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            if values.isSymbolicLink == true {
                throw ArchiveFormatError.symlinkPath(Self.relativePath(url: entry, root: root))
            }
            if values.isDirectory == true {
                throw ArchiveFormatError.unsupportedPath(Self.relativePath(url: entry, root: root))
            }
        }
        let urls = entries
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        return try urls.map { url in
            let data = try Data(contentsOf: url)
            let relativePath = Self.relativePath(url: url, root: root)
            do {
                return ArchiveMechanicsDocument(
                    relativePath: relativePath,
                    rawData: data,
                    descriptor: try JSONDecoder().decode(MechanicsModuleDescriptor.self, from: data)
                )
            } catch {
                return ArchiveMechanicsDocument(
                    relativePath: relativePath,
                    rawData: data,
                    descriptor: nil,
                    decodingError: String(describing: error)
                )
            }
        }
    }

    public func load() throws -> ArchiveMechanicsCatalog {
        ArchiveMechanicsCatalog(documents: try discover())
    }

    public func validate() throws -> ArchiveMechanicsValidationReport {
        try load().validate()
    }

    private static func relativePath(url: URL, root: URL) -> String {
        let prefix = root.standardizedFileURL.path.hasSuffix("/")
            ? root.standardizedFileURL.path
            : root.standardizedFileURL.path + "/"
        return String(url.standardizedFileURL.path.dropFirst(prefix.count))
    }
}

extension ArchiveMechanicsLoader {
    /// Reads `mechanicsModules` from each publication using the canonical
    /// dependency wire shape. Invalid entries are reported separately while
    /// the source YAML remains untouched.
    public func publicationDependencies() throws -> [String: [MechanicsModuleDependency]] {
        guard format.archiveRoot != nil else { return [:] }
        var result: [String: [MechanicsModuleDependency]] = [:]
        for file in try format.files() where file.classification.kind == .publication {
            result[file.classification.publicationID] = try parseDependencies(
                in: format.readUTF8(file.relativePath), relativePath: file.relativePath
            ).dependencies
        }
        return result
    }

    public func publicationDependencyDiagnostics() throws -> [ArchiveMechanicsDiagnostic] {
        guard format.archiveRoot != nil else { return [] }
        var diagnostics: [ArchiveMechanicsDiagnostic] = []
        for file in try format.files() where file.classification.kind == .publication {
            diagnostics.append(contentsOf: try parseDependencies(
                in: format.readUTF8(file.relativePath), relativePath: file.relativePath
            ).diagnostics)
        }
        return diagnostics
    }

    private func parseDependencies(
        in text: String,
        relativePath: String
    ) throws -> (dependencies: [MechanicsModuleDependency], diagnostics: [ArchiveMechanicsDiagnostic]) {
        let loaded: Any?
        do {
            loaded = try Yams.load(yaml: text)
        } catch {
            return ([], [.init(relativePath: relativePath, kind: .malformedDependency,
                                message: "Publication YAML could not be parsed while reading mechanicsModules.")])
        }
        guard let object = loaded as? [String: Any],
              let raw = object["mechanicsModules"] else {
            return ([], [])
        }
        guard let values = raw as? [Any] else {
            return ([], [.init(relativePath: relativePath, kind: .malformedDependency,
                                message: "mechanicsModules must be an array.")])
        }
        var dependencies: [MechanicsModuleDependency] = []
        var diagnostics: [ArchiveMechanicsDiagnostic] = []
        for (index, item) in values.enumerated() {
            guard let value = item as? [String: Any],
                  let id = value["moduleID"] as? String,
                  let moduleID = try? MechanicsModuleID(id),
                  let revision = value["revision"] as? Int,
                  revision > 0 else {
                diagnostics.append(.init(relativePath: relativePath, kind: .malformedDependency,
                    message: "mechanicsModules[\(index)] must contain a valid moduleID and positive integer revision."))
                continue
            }
            dependencies.append(.init(moduleID: moduleID, revision: revision))
        }
        return (dependencies, diagnostics)
    }
}
