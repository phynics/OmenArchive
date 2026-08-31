import Foundation
import OmenURI
import Yams

/// A resource that can satisfy an `omen://` reference.
public struct ArchiveReferenceTarget: Equatable, Hashable, Sendable {
    public let relativePath: String

    /// Creates a reference target for an archive-relative path.
    public init(relativePath: String) {
        self.relativePath = relativePath
    }
}

/// One occurrence of a reference that resolves to a target.
public struct ArchiveReferenceOccurrence: Equatable, Hashable, Sendable {
    public let relativePath: String
    public let rawValue: String
    public let path: OmenPath

    /// Creates a reference occurrence.
    public init(relativePath: String, rawValue: String, path: OmenPath) {
        self.relativePath = relativePath
        self.rawValue = rawValue
        self.path = path
    }
}

/// The severity of an archive reference diagnostic.
public enum ArchiveReferenceSeverity: String, Equatable, Hashable, Sendable {
    case warning
    case error
}

/// The reason an archive reference needs attention.
public enum ArchiveReferenceIssueKind: String, Equatable, Hashable, Sendable {
    case malformed
    case dangling
    case ambiguous
}

/// A structured diagnostic for one archive reference.
public struct ArchiveReferenceIssue: Equatable, Hashable, Sendable {
    public let relativePath: String
    public let rawValue: String
    public let severity: ArchiveReferenceSeverity
    public let kind: ArchiveReferenceIssueKind
    public let details: String

    /// Creates an archive reference issue.
    public init(
        relativePath: String,
        rawValue: String,
        severity: ArchiveReferenceSeverity,
        kind: ArchiveReferenceIssueKind,
        details: String
    ) {
        self.relativePath = relativePath
        self.rawValue = rawValue
        self.severity = severity
        self.kind = kind
        self.details = details
    }
}

/// Validates `omen://` references after a caller supplies archive resolution.
///
/// `ArchiveFormat` owns filesystem and schema policy. The application that
/// knows its resource model supplies the path resolver through `resolve`.
/// This keeps reference diagnostics identical for staged files, editor text,
/// publication checks, and command-line conversion without coupling this kit
/// to an application's resource-entry type.
public struct ArchiveReferenceValidator: Sendable {
    public typealias Resolve = @Sendable (OmenPath) throws -> [ArchiveReferenceTarget]

    private let format: ArchiveFormat
    private let resolve: Resolve

    /// Creates a validator for an archive format and resource resolver.
    public init(format: ArchiveFormat, resolve: @escaping Resolve) {
        self.format = format
        self.resolve = resolve
    }

    /// Scans all authored YAML files, optionally limited to one publication.
    public func scan(publicationID: String? = nil) throws -> [ArchiveReferenceIssue] {
        var issues: [ArchiveReferenceIssue] = []

        for file in try format.files() {
            guard file.relativePath.hasSuffix(".yml") else { continue }
            guard publicationID == nil || file.classification.publicationID == publicationID else { continue }
            guard let values = try? values(in: format.readUTF8(file.relativePath)) else { continue }

            for rawValue in Self.referenceValues(in: values) {
                issues.append(contentsOf: try validate(rawValue: rawValue, relativePath: file.relativePath))
            }
        }

        return issues.sorted {
            if $0.relativePath != $1.relativePath { return $0.relativePath < $1.relativePath }
            if $0.rawValue != $1.rawValue { return $0.rawValue < $1.rawValue }
            return $0.kind.rawValue < $1.kind.rawValue
        }
    }

    /// Validates references in unsaved editor text.
    public func validate(text: String, relativePath: String) throws -> [ArchiveReferenceIssue] {
        guard let values = try? values(in: text) else { return [] }
        return try Self.referenceValues(in: values).flatMap {
            try validate(rawValue: $0, relativePath: relativePath)
        }
    }

    /// Validates one reference value against the supplied resource resolver.
    public func validate(rawValue: String, relativePath: String) throws -> [ArchiveReferenceIssue] {
        guard let path = OmenPath(url: URL(string: rawValue) ?? URL(fileURLWithPath: "")) else {
            return [ArchiveReferenceIssue(
                relativePath: relativePath,
                rawValue: rawValue,
                severity: .error,
                kind: .malformed,
                details: "Malformed OmenPath reference: \(rawValue)"
            )]
        }

        let matches = try resolve(path)
        guard !matches.isEmpty else {
            return [ArchiveReferenceIssue(
                relativePath: relativePath,
                rawValue: rawValue,
                severity: .error,
                kind: .dangling,
                details: "OmenPath reference does not resolve in the archive: \(rawValue)"
            )]
        }

        guard matches.count > 1 else { return [] }
        return [ArchiveReferenceIssue(
            relativePath: relativePath,
            rawValue: rawValue,
            severity: .warning,
            kind: .ambiguous,
            details: "Unscoped OmenPath reference matches \(matches.count) archive resources: \(rawValue)"
        )]
    }

    /// Returns every `omen://` string nested in a YAML value.
    public static func referenceValues(in value: Any) -> [String] {
        switch value {
        case let mapping as [String: Any]:
            return mapping.values.flatMap(referenceValues(in:))
        case let mapping as [AnyHashable: Any]:
            return mapping.values.flatMap(referenceValues(in:))
        case let array as [Any]:
            return array.flatMap(referenceValues(in:))
        case let string as String where string.hasPrefix("omen://"):
            return [string]
        default:
            return []
        }
    }

    private func values(in text: String) throws -> Any {
        guard let value = try Yams.load(yaml: text) else {
            throw ArchiveReferenceValidationError.invalidYAML
        }
        return value
    }
}

private enum ArchiveReferenceValidationError: Error {
    case invalidYAML
}
