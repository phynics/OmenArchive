import Foundation
import OmenURI

/// The archive's language-neutral directory contract.
///
/// The manifest is deliberately loaded from the archive root instead of being
/// embedded in this package. This keeps schemas and format declarations
/// versioned with the authored data they govern.
public struct ArchiveFormatManifest: Codable, Equatable, Sendable {
    public struct Publication: Codable, Equatable, Sendable {
        public let path: String
        public let schema: String

        public init(path: String, schema: String) {
            self.path = path
            self.schema = schema
        }
    }

    public struct Family: Codable, Equatable, Sendable {
        public enum Layout: String, Codable, Equatable, Sendable {
            case flat
            case bundle
            case grouped
            case openCustomGroup = "open-custom-group"
        }

        public let id: String
        public let directory: String
        public let layout: Layout
        public let schema: String
        public let children: [Child]
        public let allowsCustomChildren: Bool
        public let customChildSchema: String?

        public init(
            id: String,
            directory: String,
            layout: Layout,
            schema: String,
            children: [Child] = [],
            allowsCustomChildren: Bool = false,
            customChildSchema: String? = nil
        ) {
            self.id = id
            self.directory = directory
            self.layout = layout
            self.schema = schema
            self.children = children
            self.allowsCustomChildren = allowsCustomChildren
            self.customChildSchema = customChildSchema
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            directory = try container.decode(String.self, forKey: .directory)
            layout = try container.decode(Layout.self, forKey: .layout)
            schema = try container.decode(String.self, forKey: .schema)
            children = try container.decodeIfPresent([Child].self, forKey: .children) ?? []
            allowsCustomChildren = try container.decodeIfPresent(Bool.self, forKey: .allowsCustomChildren) ?? false
            customChildSchema = try container.decodeIfPresent(String.self, forKey: .customChildSchema)
        }

        public struct Child: Codable, Equatable, Sendable {
            public let directory: String
            public let layout: Layout
            public let schema: String

            public init(directory: String, layout: Layout, schema: String) {
                self.directory = directory
                self.layout = layout
                self.schema = schema
            }
        }
    }

    /// A custom child group owned by one bundle resource.
    ///
    /// `ownerPath` contains the already-slugged path components between the
    /// family directory and the declared group. For example, the class-owned
    /// bard muses group is represented as `familyID: class`,
    /// `ownerPath: [bard]`, and `directory: muses`.
    public struct CustomGroup: Codable, Equatable, Sendable {
        public let familyID: String
        public let ownerPath: [String]
        public let directory: String
        public let schema: String

        public init(
            familyID: String,
            ownerPath: [String],
            directory: String,
            schema: String
        ) {
            self.familyID = familyID
            self.ownerPath = ownerPath
            self.directory = directory
            self.schema = schema
        }
    }

    public let version: Int
    public let publication: Publication
    public let families: [Family]
    public let customGroups: [CustomGroup]

    public init(
        version: Int,
        publication: Publication,
        families: [Family],
        customGroups: [CustomGroup] = []
    ) {
        self.version = version
        self.publication = publication
        self.families = families
        self.customGroups = customGroups
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        publication = try container.decode(Publication.self, forKey: .publication)
        families = try container.decode([Family].self, forKey: .families)
        customGroups = try container.decodeIfPresent([CustomGroup].self, forKey: .customGroups) ?? []
    }
}

public enum ArchiveFormatError: Error, Equatable, Sendable, CustomStringConvertible, LocalizedError {
    case missingManifest(URL)
    case invalidManifest(URL, String)
    case archiveRootRequired
    case invalidPath(String)
    case unsupportedPath(String)
    case ambiguousFamily(String)
    case undeclaredCustomGroup(familyID: String, ownerPath: [String], directory: String)
    case symlinkPath(String)
    case unreadablePath(String)
    case invalidUTF8(String)

    public var description: String {
        switch self {
        case .missingManifest(let url):
            return "Archive format manifest is missing: \(url.path)"
        case .invalidManifest(let url, let reason):
            return "Archive format manifest is invalid at \(url.path): \(reason)"
        case .archiveRootRequired:
            return "Archive root is required for filesystem operations"
        case .invalidPath(let path):
            return "Archive path is invalid: \(path)"
        case .unsupportedPath(let path):
            return "Archive path is not described by the format manifest: \(path)"
        case .ambiguousFamily(let directory):
            return "Archive format has multiple families for directory: \(directory)"
        case .undeclaredCustomGroup(let familyID, let ownerPath, let directory):
            let owner = ownerPath.isEmpty ? "<root>" : ownerPath.joined(separator: "/")
            return "Archive format does not declare custom group \(familyID)/\(owner)/\(directory)"
        case .symlinkPath(let path):
            return "Archive symlinks are not allowed: \(path)"
        case .unreadablePath(let path):
            return "Archive path cannot be read: \(path)"
        case .invalidUTF8(let path):
            return "Archive file is not valid UTF-8: \(path)"
        }
    }

    public var errorDescription: String? {
        description
    }
}

public struct ArchiveFile: Equatable, Sendable {
    public let relativePath: String
    public let url: URL
    public let classification: ArchivePathClassification

    public init(relativePath: String, url: URL, classification: ArchivePathClassification) {
        self.relativePath = relativePath
        self.url = url
        self.classification = classification
    }
}

public struct ArchivePathClassification: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case publication
        case resource(familyID: String)
    }

    public let kind: Kind
    public let publicationID: String
    public let relativePath: String
    public let schema: String
    public let layout: ArchiveFormatManifest.Family.Layout?
    public let resourceParts: [String]

    public init(
        kind: Kind,
        publicationID: String,
        relativePath: String,
        schema: String,
        layout: ArchiveFormatManifest.Family.Layout?,
        resourceParts: [String]
    ) {
        self.kind = kind
        self.publicationID = publicationID
        self.relativePath = relativePath
        self.schema = schema
        self.layout = layout
        self.resourceParts = resourceParts
    }
}

/// Interprets archive-relative paths using the committed archive manifest.
///
/// This is intentionally a path/layout module, not a schema validator. It
/// gives traversal, browser, writer, and validator clients one authoritative
/// answer to “what family and schema does this path represent?” before YAML
/// decoding is attempted.
public struct ArchiveFormat: Sendable {
    public static let manifestFileName = "archive-format.json"

    public let manifest: ArchiveFormatManifest
    public let archiveRoot: URL?

    public init(manifest: ArchiveFormatManifest) throws {
        try Self.validateManifest(manifest)
        self.manifest = manifest
        self.archiveRoot = nil
    }

    public init(archiveRoot: URL) throws {
        try Self.ensureNoSymlink(archiveRoot, label: "archive root")
        let schemasRoot = archiveRoot.appendingPathComponent("schemas", isDirectory: true)
        try Self.ensureNoSymlink(schemasRoot, label: "schemas")
        let manifestURL = schemasRoot
            .appendingPathComponent(Self.manifestFileName)
        try Self.ensureNoSymlink(manifestURL, label: "schemas/\(Self.manifestFileName)")
        guard FileManager.default.fileExists(atPath: manifestURL.path) else {
            throw ArchiveFormatError.missingManifest(manifestURL)
        }

        do {
            let data = try Data(contentsOf: manifestURL)
            let decoder = JSONDecoder()
            self.manifest = try decoder.decode(ArchiveFormatManifest.self, from: data)
            try Self.validateManifest(self.manifest)
        } catch let error as ArchiveFormatError {
            throw error
        } catch {
            throw ArchiveFormatError.invalidManifest(manifestURL, error.localizedDescription)
        }
        try Self.validateSchemaFiles(for: self.manifest, under: archiveRoot, manifestURL: manifestURL)
        self.archiveRoot = archiveRoot.standardizedFileURL
    }

    public func schemaURL(for classification: ArchivePathClassification) -> URL? {
        guard let archiveRoot else { return nil }
        return archiveRoot
            .appendingPathComponent("schemas", isDirectory: true)
            .appendingPathComponent(classification.schema)
    }

    /// Returns the declaration that authorized a custom child classification.
    /// Standard children and open global groups return `nil`.
    public func customGroup(for classification: ArchivePathClassification) -> ArchiveFormatManifest.CustomGroup? {
        guard case .resource(let familyID) = classification.kind,
              classification.resourceParts.count >= 3 else {
            return nil
        }
        let ownerPath = Array(classification.resourceParts.dropLast(2))
        let directory = classification.resourceParts[classification.resourceParts.count - 2]
        return manifest.customGroups.first {
            $0.familyID == familyID
                && $0.ownerPath == ownerPath
                && $0.directory == directory
        }
    }

    /// Enumerates authored YAML files in stable relative-path order.
    /// Hidden files, non-regular files, and symlinks never become archive
    /// inputs; a symlink is rejected rather than silently followed.
    public func files() throws -> [ArchiveFile] {
        guard let archiveRoot else { throw ArchiveFormatError.archiveRootRequired }
        let root = archiveRoot.standardizedFileURL
        let sourceRoot = root.appendingPathComponent("src", isDirectory: true)
        try Self.ensureNoSymlink(sourceRoot, label: "src")
        guard FileManager.default.fileExists(atPath: sourceRoot.path) else {
            throw ArchiveFormatError.unreadablePath("src")
        }

        let keys: [URLResourceKey] = [
            .isDirectoryKey,
            .isRegularFileKey,
            .isSymbolicLinkKey
        ]
        guard let enumerator = FileManager.default.enumerator(
            at: sourceRoot,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else {
            throw ArchiveFormatError.unreadablePath("src")
        }

        var result: [ArchiveFile] = []
        for case let fileURL as URL in enumerator {
            let values: URLResourceValues
            do {
                values = try fileURL.resourceValues(forKeys: Set(keys))
            } catch {
                throw ArchiveFormatError.unreadablePath(relativePath(for: fileURL, under: root))
            }
            let relative = relativePath(for: fileURL, under: root)
            if values.isSymbolicLink == true {
                throw ArchiveFormatError.symlinkPath(relative)
            }
            if values.isDirectory == true { continue }
            guard values.isRegularFile == true else { continue }
            guard relative.hasSuffix(".yml") else { continue }

            let classification = try classify(relative)
            result.append(ArchiveFile(relativePath: relative, url: fileURL, classification: classification))
        }

        return result.sorted {
            Data($0.relativePath.utf8).lexicographicallyPrecedes(Data($1.relativePath.utf8))
        }
    }

    /// Reads one authored archive file as UTF-8 after applying the same path
    /// and symlink checks used by `files()`.
    public func readUTF8(_ relativePath: String) throws -> String {
        guard let archiveRoot else { throw ArchiveFormatError.archiveRootRequired }
        let normalized = try classify(relativePath).relativePath
        let root = archiveRoot.standardizedFileURL
        let fileURL = root.appendingPathComponent(normalized)
        let values: URLResourceValues
        do {
            values = try fileURL.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey])
        } catch {
            throw ArchiveFormatError.unreadablePath(normalized)
        }
        guard values.isSymbolicLink != true else {
            throw ArchiveFormatError.symlinkPath(normalized)
        }
        guard values.isDirectory != true, values.isRegularFile == true else {
            throw ArchiveFormatError.unreadablePath(normalized)
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw ArchiveFormatError.unreadablePath(normalized)
        }
        if data.starts(with: [0xFF, 0xFE]) || data.starts(with: [0xFE, 0xFF]) || data.contains(0) {
            throw ArchiveFormatError.invalidUTF8(normalized)
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw ArchiveFormatError.invalidUTF8(normalized)
        }
        return text
    }

    public func classify(_ relativePath: String) throws -> ArchivePathClassification {
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/"),
              !relativePath.hasSuffix("/"),
              !relativePath.contains("//"),
              !relativePath.contains("\\"),
              !relativePath.unicodeScalars.contains(where: { $0.value == 0 }) else {
            throw ArchiveFormatError.invalidPath(relativePath)
        }
        let normalized = relativePath
        let components = normalized.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard !components.isEmpty else { throw ArchiveFormatError.invalidPath(relativePath) }
        guard !components.contains(".."), !components.contains(".") else {
            throw ArchiveFormatError.invalidPath(relativePath)
        }
        guard !components.contains(where: { $0.hasPrefix(".") }) else {
            throw ArchiveFormatError.unsupportedPath(relativePath)
        }
        guard components.first == "src", components.count >= 3 else {
            throw ArchiveFormatError.unsupportedPath(relativePath)
        }

        let publicationID = components[1]
        let fileName = components.last!
        guard fileName.hasSuffix(".yml") else {
            throw ArchiveFormatError.unsupportedPath(relativePath)
        }

        if components.count == 3,
           fileName == "publication.yml" {
            return ArchivePathClassification(
                kind: .publication,
                publicationID: publicationID,
                relativePath: normalized,
                schema: manifest.publication.schema,
                layout: nil,
                resourceParts: []
            )
        }

        guard components.count >= 4 else {
            throw ArchiveFormatError.unsupportedPath(relativePath)
        }
        let directory = components[2]
        let families = manifest.families.filter { $0.directory == directory }
        guard !families.isEmpty else {
            throw ArchiveFormatError.unsupportedPath(relativePath)
        }
        guard families.count == 1, let family = families.first else {
            throw ArchiveFormatError.ambiguousFamily(directory)
        }

        let resourceParts = Array(components.dropFirst(3))
        let schema: String
        let layout: ArchiveFormatManifest.Family.Layout
        switch family.layout {
        case .flat:
            guard resourceParts.count == 1 else {
                throw ArchiveFormatError.unsupportedPath(relativePath)
            }
            schema = family.schema
            layout = family.layout
        case .bundle:
            guard resourceParts.count >= 2 else {
                throw ArchiveFormatError.unsupportedPath(relativePath)
            }
            let bundleName = resourceParts[0]
            let leafName = URL(fileURLWithPath: resourceParts[1]).deletingPathExtension().lastPathComponent
            if resourceParts.count == 2, leafName == bundleName {
                schema = family.schema
                layout = family.layout
            } else {
                guard resourceParts.count == 3 else {
                    throw ArchiveFormatError.unsupportedPath(relativePath)
                }
                if let child = family.children.first(where: { $0.directory == resourceParts[1] }) {
                    guard child.layout == .flat else {
                        throw ArchiveFormatError.unsupportedPath(relativePath)
                    }
                    schema = child.schema
                } else {
                    let ownerPath = Array(resourceParts.dropLast(2))
                    if let declaration = manifest.customGroups.first(where: {
                        $0.familyID == family.id
                            && $0.ownerPath == ownerPath
                            && $0.directory == resourceParts[1]
                    }) {
                        schema = declaration.schema
                    } else if !manifest.customGroups.filter({ $0.familyID == family.id }).isEmpty {
                        throw ArchiveFormatError.undeclaredCustomGroup(
                            familyID: family.id,
                            ownerPath: ownerPath,
                            directory: resourceParts[1]
                        )
                    } else {
                        throw ArchiveFormatError.unsupportedPath(relativePath)
                    }
                }
                layout = .flat
            }
        case .grouped:
            guard resourceParts.count == 2 else {
                throw ArchiveFormatError.unsupportedPath(relativePath)
            }
            schema = family.schema
            layout = family.layout
        case .openCustomGroup:
            guard resourceParts.count == 2 else {
                throw ArchiveFormatError.unsupportedPath(relativePath)
            }
            schema = family.schema
            layout = family.layout
        }

        return ArchivePathClassification(
            kind: .resource(familyID: family.id),
            publicationID: publicationID,
            relativePath: normalized,
            schema: schema,
            layout: layout,
            resourceParts: resourceParts
        )
    }

    /// Builds and validates an authored path from a manifest family and its
    /// already-slugged resource components.
    ///
    /// Writers use this seam instead of duplicating the manifest's directory
    /// selection and layout rules. The returned path is archive-relative and
    /// is guaranteed to be accepted by ``classify(_:)``.
    public func archivePath(
        familyID: String,
        publicationID: String,
        resourceParts: [String]
    ) throws -> String {
        guard let family = manifest.families.first(where: { $0.id == familyID }) else {
            throw ArchiveFormatError.unsupportedPath(
                (["src", publicationID, familyID] + resourceParts).joined(separator: "/")
            )
        }

        let relativePath = (["src", publicationID, family.directory] + resourceParts)
            .joined(separator: "/")
        _ = try classify(relativePath)
        return relativePath
    }

    /// Returns the canonical storage slug candidates for a resource name.
    /// The first candidate is the strict normalized slug; later candidates
    /// retain punctuation simplifications used by existing archive filenames.
    public func expectedSlugs(for name: String, classification: ArchivePathClassification) -> [String] {
        let primary = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" && $0 != "(" && $0 != ")" })
            .map(String.init)
            .joined(separator: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        var result = [
            primary,
            name.omenPathEncoding,
            primary.replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
        ]
        if case .resource(let familyID) = classification.kind,
           familyID == "domain" {
            let suffix = "-domain"
            if primary.hasSuffix(suffix) {
                result.append(String(primary.dropLast(suffix.count)))
            }
        }
        return result.filter { !$0.isEmpty }.reduce(into: []) { values, candidate in
            if !values.contains(candidate) { values.append(candidate) }
        }
    }

    private static func validateManifest(_ manifest: ArchiveFormatManifest) throws {
        guard manifest.version == 1 else {
            throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "unsupported version \(manifest.version)")
        }
        guard manifest.publication.path == "src/{publication}/publication.yml" else {
            throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "publication path must be src/{publication}/publication.yml")
        }
        guard !manifest.families.isEmpty else {
            throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "families must not be empty")
        }
        let schemaNames = [manifest.publication.schema]
            + manifest.families.flatMap { family in
                [family.schema] + family.children.map(\.schema) + (family.customChildSchema.map { [$0] } ?? [])
            }
            + manifest.customGroups.map(\.schema)
        for schemaName in schemaNames where !isSafeSchemaName(schemaName) {
            throw ArchiveFormatError.invalidManifest(
                URL(fileURLWithPath: manifestFileName),
                "schema name is not a safe file name: \(schemaName)"
            )
        }
        var directories = Set<String>()
        var ids = Set<String>()
        for family in manifest.families {
            guard !family.id.isEmpty, !family.directory.isEmpty, !family.schema.isEmpty else {
                throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "family fields must not be empty")
            }
            guard ids.insert(family.id).inserted else {
                throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "duplicate family id \(family.id)")
            }
            guard directories.insert(family.directory).inserted else {
                throw ArchiveFormatError.ambiguousFamily(family.directory)
            }
            if family.layout != .bundle, !family.children.isEmpty {
                throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "only bundle families may declare children")
            }
            if family.allowsCustomChildren && family.layout != .bundle {
                throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "custom children require a bundle family")
            }
            if family.allowsCustomChildren && family.customChildSchema == nil {
                throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "custom children require a schema")
            }
            var childDirectories = Set<String>()
            for child in family.children {
                guard childDirectories.insert(child.directory).inserted else {
                    throw ArchiveFormatError.invalidManifest(URL(fileURLWithPath: manifestFileName), "duplicate child directory \(child.directory)")
                }
            }
        }

        let familyByID = Dictionary(uniqueKeysWithValues: manifest.families.map { ($0.id, $0) })
        var customGroupKeys = Set<String>()
        for customGroup in manifest.customGroups {
            guard let family = familyByID[customGroup.familyID] else {
                throw ArchiveFormatError.invalidManifest(
                    URL(fileURLWithPath: manifestFileName),
                    "custom group references unknown family \(customGroup.familyID)"
                )
            }
            guard family.layout == .bundle else {
                throw ArchiveFormatError.invalidManifest(
                    URL(fileURLWithPath: manifestFileName),
                    "custom groups require a bundle family: \(customGroup.familyID)"
                )
            }
            guard !customGroup.ownerPath.isEmpty,
                  customGroup.ownerPath.allSatisfy(isSafePathComponent),
                  isSafePathComponent(customGroup.directory),
                  !customGroup.schema.isEmpty else {
                throw ArchiveFormatError.invalidManifest(
                    URL(fileURLWithPath: manifestFileName),
                    "custom group contains an unsafe owner, directory, or schema"
                )
            }
            guard !family.children.contains(where: { $0.directory == customGroup.directory }) else {
                throw ArchiveFormatError.invalidManifest(
                    URL(fileURLWithPath: manifestFileName),
                    "custom group duplicates child directory \(customGroup.directory)"
                )
            }
            let key = ([customGroup.familyID] + customGroup.ownerPath + [customGroup.directory]).joined(separator: "/")
            guard customGroupKeys.insert(key).inserted else {
                throw ArchiveFormatError.invalidManifest(
                    URL(fileURLWithPath: manifestFileName),
                    "duplicate custom group \(key)"
                )
            }
        }
    }

    private static func validateSchemaFiles(
        for manifest: ArchiveFormatManifest,
        under archiveRoot: URL,
        manifestURL: URL
    ) throws {
        let schemaRoot = archiveRoot.appendingPathComponent("schemas", isDirectory: true)
        let schemaNames = [manifest.publication.schema]
            + manifest.families.flatMap { family in
                [family.schema]
                    + family.children.map(\.schema)
                    + (family.customChildSchema.map { [$0] } ?? [])
            }
            + manifest.customGroups.map(\.schema)

        for schemaName in Set(schemaNames).sorted() {
            guard isSafeSchemaName(schemaName) else {
                throw ArchiveFormatError.invalidManifest(
                    manifestURL,
                    "schema name is not a safe file name: \(schemaName)"
                )
            }
            let schemaURL = schemaRoot.appendingPathComponent(schemaName)
            try ensureNoSymlink(schemaURL, label: "schemas/\(schemaName)")
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: schemaURL.path, isDirectory: &isDirectory),
                  !isDirectory.boolValue else {
                throw ArchiveFormatError.invalidManifest(
                    manifestURL,
                    "schema file is missing: \(schemaName)"
                )
            }
        }
    }

    private static func isSafeSchemaName(_ schemaName: String) -> Bool {
        schemaName.split(separator: "/").count == 1
            && !schemaName.contains("\\")
            && !schemaName.isEmpty
            && schemaName != "."
            && schemaName != ".."
    }

    private static func isSafePathComponent(_ value: String) -> Bool {
        !value.isEmpty
            && value != "."
            && value != ".."
            && !value.contains("/")
            && !value.contains("\\")
            && !value.unicodeScalars.contains(where: { $0.value == 0 })
    }

    private static func ensureNoSymlink(_ url: URL, label: String) throws {
        let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
        if values.isSymbolicLink == true {
            throw ArchiveFormatError.symlinkPath(label)
        }
    }

    private func relativePath(for url: URL, under root: URL) -> String {
        // Foundation may canonicalize a temporary directory through `/private`
        // while the URL supplied by the caller retains `/var` (and `/tmp`
        // similarly resolves to `/private/tmp`). Compare resolved paths so
        // temporary fixture archives behave like real checkout paths without
        // weakening the explicit symlink rejection above.
        let resolvedRoot = root.resolvingSymlinksInPath()
        let resolvedURL = url.resolvingSymlinksInPath()
        let prefix = resolvedRoot.path.hasSuffix("/") ? resolvedRoot.path : resolvedRoot.path + "/"
        return resolvedURL.path.hasPrefix(prefix)
            ? String(resolvedURL.path.dropFirst(prefix.count)).replacingOccurrences(of: "\\", with: "/")
            : url.lastPathComponent
    }
}
