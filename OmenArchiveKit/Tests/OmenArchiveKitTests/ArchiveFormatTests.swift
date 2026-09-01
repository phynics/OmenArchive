import Foundation
import Testing
@testable import OmenArchiveKit

@Suite("Archive format path contract")
struct ArchiveFormatTests {
    private let format: ArchiveFormat

    init() throws {
        let fixtureURL = Bundle.module.url(forResource: "archive-format", withExtension: "json")!
        let manifest = try JSONDecoder().decode(
            ArchiveFormatManifest.self,
            from: Data(contentsOf: fixtureURL)
        )
        format = try ArchiveFormat(manifest: manifest)
    }

    @Test("describes format errors with an actionable message")
    func formatErrorsExposeTheirDescription() {
        let manifestURL = URL(fileURLWithPath: "/tmp/archive/schemas/archive-format.json")
        let error: any Error = ArchiveFormatError.missingManifest(manifestURL)

        #expect(error.localizedDescription.contains("Archive format manifest is missing"))
        #expect(error.localizedDescription.contains(manifestURL.path))
    }

    @Test("classifies publication metadata")
    func publication() throws {
        let result = try format.classify("src/test-book/publication.yml")
        #expect(result.kind == .publication)
        #expect(result.schema == "publication.schema.json")
        #expect(result.publicationID == "test-book")
    }

    @Test("selects the family schema for flat resources")
    func flatResource() throws {
        let result = try format.classify("src/test-book/spell/fireball.yml")
        #expect(result.kind == .resource(familyID: "spell"))
        #expect(result.schema == "character-spell.schema.json")
        #expect(result.layout == .flat)
        #expect(result.resourceParts == ["fireball.yml"])
    }

    @Test("recognizes bundle mains and child records")
    func bundleResource() throws {
        let main = try format.classify("src/test-book/ancestry/elf/elf.yml")
        #expect(main.kind == .resource(familyID: "ancestry"))
        #expect(main.schema == "character-ancestry.schema.json")
        #expect(main.layout == .bundle)

        let child = try format.classify("src/test-book/ancestry/elf/features/ancient-elf.yml")
        #expect(child.kind == .resource(familyID: "ancestry"))
        #expect(child.schema == "character-feature.schema.json")
        #expect(child.layout == .flat)

        let customChild = try format.classify("src/test-book/class/ranger/hunters-edge/flurry.yml")
        #expect(customChild.kind == .resource(familyID: "class"))
        #expect(customChild.schema == "character-feature.schema.json")
    }

    @Test("requires declared owner-scoped custom groups")
    func declaredCustomGroup() throws {
        let classification = try format.classify(
            "src/test-book/class/ranger/custom-group/feature.yml"
        )
        #expect(
            format.customGroup(for: classification)
                == ArchiveFormatManifest.CustomGroup(
                    familyID: "class",
                    ownerPath: ["ranger"],
                    directory: "custom-group",
                    schema: "character-feature.schema.json"
                )
        )
        #expect(throws: ArchiveFormatError.undeclaredCustomGroup(
            familyID: "class",
            ownerPath: ["ranger"],
            directory: "unknown-group"
        )) {
            try format.classify("src/test-book/class/ranger/unknown-group/feature.yml")
        }
    }

    @Test("rejects duplicate custom-group declarations")
    func duplicateCustomGroupDeclaration() {
        let family = ArchiveFormatManifest.Family(
            id: "class",
            directory: "class",
            layout: .bundle,
            schema: "class.json"
        )
        let declaration = ArchiveFormatManifest.CustomGroup(
            familyID: "class",
            ownerPath: ["ranger"],
            directory: "hunters-edge",
            schema: "feature.json"
        )
        let manifest = ArchiveFormatManifest(
            version: 1,
            publication: .init(path: "src/{publication}/publication.yml", schema: "publication.json"),
            families: [family],
            customGroups: [declaration, declaration]
        )

        #expect(throws: ArchiveFormatError.invalidManifest(
            URL(fileURLWithPath: ArchiveFormat.manifestFileName),
            "duplicate custom group class/ranger/hunters-edge"
        )) {
            try ArchiveFormat(manifest: manifest)
        }
    }

    @Test("keeps grouped and flat layouts explicit")
    func groupedAndFlat() throws {
        let grouped = try format.classify("src/test-book/heritage/elf/woodland-elf.yml")
        #expect(grouped.layout == .grouped)
        #expect(grouped.schema == "character-heritage.schema.json")

        let domain = try format.classify("src/test-book/domain/air.yml")
        #expect(domain.kind == .resource(familyID: "domain"))
        #expect(domain.layout == .flat)
        #expect(domain.schema == "character-domain.schema.json")

        let companion = try format.classify("src/test-book/companion/test-companion.yml")
        #expect(companion.kind == .resource(familyID: "companion"))
        #expect(companion.schema == "character-companion.schema.json")

        let archetype = try format.classify(
            "src/test-book/archetype/test-archetype/feats/test-dedication.yml"
        )
        #expect(archetype.kind == .resource(familyID: "archetype"))
        #expect(archetype.schema == "character-feat.schema.json")
    }

    @Test("builds writer paths from the declared family directory and layout")
    func archivePathUsesManifestLayout() throws {
        #expect(
            try format.archivePath(
                familyID: "spell",
                publicationID: "test-book",
                resourceParts: ["fireball.yml"]
            ) == "src/test-book/spell/fireball.yml"
        )
        #expect(
            try format.archivePath(
                familyID: "class",
                publicationID: "test-book",
                resourceParts: ["ranger", "ranger.yml"]
            ) == "src/test-book/class/ranger/ranger.yml"
        )
        #expect(
            try format.archivePath(
                familyID: "class",
                publicationID: "test-book",
                resourceParts: ["ranger", "custom-group", "feature.yml"]
            ) == "src/test-book/class/ranger/custom-group/feature.yml"
        )
        #expect(
            try format.archivePath(
                familyID: "domain",
                publicationID: "test-book",
                resourceParts: ["air.yml"]
            ) == "src/test-book/domain/air.yml"
        )
    }

    @Test("rejects writer paths outside the declared family layout")
    func archivePathRejectsUnsupportedLayout() throws {
        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/spell/fireball/extra.yml")) {
            try format.archivePath(
                familyID: "spell",
                publicationID: "test-book",
                resourceParts: ["fireball", "extra.yml"]
            )
        }
    }

    @Test("rejects paths outside the declared layout")
    func rejectsUnsupportedPaths() throws {
        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/spell/fireball/extra.yml")) {
            try format.classify("src/test-book/spell/fireball/extra.yml")
        }
        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/unknown/fireball.yml")) {
            try format.classify("src/test-book/unknown/fireball.yml")
        }
        #expect(throws: ArchiveFormatError.invalidPath("../src/test-book/spell/fireball.yml")) {
            try format.classify("../src/test-book/spell/fireball.yml")
        }
        #expect(throws: ArchiveFormatError.invalidPath("src//test-book/spell/fireball.yml")) {
            try format.classify("src//test-book/spell/fireball.yml")
        }
        #expect(throws: ArchiveFormatError.invalidPath("src\\test-book\\spell\\fireball.yml")) {
            try format.classify("src\\test-book\\spell\\fireball.yml")
        }
        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/spell/Fireball.YML")) {
            try format.classify("src/test-book/spell/Fireball.YML")
        }
        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/spell/.hidden.yml")) {
            try format.classify("src/test-book/spell/.hidden.yml")
        }
    }

    @Test("produces deterministic accepted filename slugs")
    func expectedSlugs() throws {
        let classification = try format.classify("src/test-book/domain/air.yml")
        #expect(format.expectedSlugs(for: "Air Domain", classification: classification) == ["air-domain", "air"])
        #expect(format.expectedSlugs(for: "A Rogue's Racket", classification: classification) == ["a-rogue's-racket", "a-rogues-racket"])
        #expect(format.expectedSlugs(for: "Fire.Ball", classification: try format.classify("src/test-book/spell/fireball.yml")) == ["fire-ball", "fireball"])
    }

    @Test("loads the authoritative archive manifest", .enabled(if: hasAuthoritativeArchive))
    func authoritativeManifest() throws {
        let archiveFormat = try authoritativeArchiveFormat()
        let result = try archiveFormat.classify("src/paizo-pathfinder-player-core/class/wizard/features/arcane-school.yml")
        #expect(result.schema == "character-feature.schema.json")
        #expect(result.kind == .resource(familyID: "class"))
        let customResult = try archiveFormat.classify("src/paizo-pathfinder-player-core/class/ranger/features/1-flurry.yml")
        #expect(customResult.schema == "character-feature.schema.json")
    }

    @Test("enumerates authored files deterministically", .enabled(if: hasAuthoritativeArchive))
    func enumeratesFiles() throws {
        let files = try authoritativeArchiveFormat().files()
        #expect(files.count == 1761)
        #expect(files.map(\.relativePath) == files.map(\.relativePath).sorted())
        #expect(files.first?.relativePath == "src/paizo-pathfinder-player-core/action/administer-first-aid.yml")
        #expect(files.allSatisfy { $0.relativePath.hasSuffix(".yml") || $0.relativePath.hasSuffix(".yaml") })
    }

    @Test("reads authored YAML as UTF-8", .enabled(if: hasAuthoritativeArchive))
    func readsUTF8() throws {
        let text = try authoritativeArchiveFormat().readUTF8(
            "src/paizo-pathfinder-player-core/spell/fireball.yml"
        )
        #expect(text.contains("name:"))
    }

    @Test("requires an archive root for filesystem operations")
    func filesystemOperationsRequireRoot() {
        #expect(throws: ArchiveFormatError.archiveRootRequired) {
            try format.files()
        }
    }

    @Test("rejects a symlinked archive root", .enabled(if: hasAuthoritativeArchive))
    func rejectsSymlinkedRoot() throws {
        let fileManager = FileManager.default
        let link = fileManager.temporaryDirectory
            .appendingPathComponent("omen-archive-link-\(UUID().uuidString)")
        try fileManager.createSymbolicLink(at: link, withDestinationURL: authoritativeArchiveRoot())
        defer { try? fileManager.removeItem(at: link) }

        #expect(throws: ArchiveFormatError.symlinkPath("archive root")) {
            try ArchiveFormat(archiveRoot: link)
        }
    }

    @Test("validates representative authored YAML through the package seam", .enabled(if: hasAuthoritativeArchive))
    func validatesRepresentativeYAML() throws {
        let validator = ArchiveValidator(format: try authoritativeArchiveFormat())
        try validator.validate("src/paizo-pathfinder-player-core/spell/fireball.yml")
        try validator.validate("src/paizo-pathfinder-player-core/item/wooden-shield.yml")
        try validator.validate("src/paizo-pathfinder-player-core/class/ranger/features/1-flurry.yml")
    }

    @Test("validates the complete current archive", .enabled(if: hasAuthoritativeArchive))
    func validatesCompleteArchive() throws {
        let report = try ArchiveValidator(format: try authoritativeArchiveFormat()).validateAll()
        #expect(report.filesValidated == 1761)
        #expect(report.isValid)
        #expect(report.diagnostics.isEmpty)
    }

    @Test("matches the package validator fixture outcomes", .enabled(if: hasAuthoritativeArchive))
    func matchesPackageFixtureOutcomes() throws {
        let validFixtures = [
            "valid-background",
            "valid-domain",
            "valid-class",
            "valid-school",
            "valid-feat"
        ]
        let expectedDiagnostics = [
            "invalid-duplicate-background-variant-key": "duplicated",
            "invalid-feat-type": "type",
            "invalid-missing-book": "source.book",
            "invalid-schema": "skillOption",
            "invalid-name-and-heritage": "filename slug",
            "invalid-utf16": "UTF-8"
        ]

        for fixture in validFixtures {
            let report = try validateFixture(named: fixture)
            #expect(report.isValid, "expected valid fixture \(fixture), got \(report.diagnostics)")
        }
        for (fixture, diagnostic) in expectedDiagnostics {
            let report = try validateFixture(named: fixture)
            #expect(!report.isValid, "expected invalid fixture \(fixture) to fail")
            #expect(report.diagnostics.contains { $0.message.localizedCaseInsensitiveContains(diagnostic) })
        }
    }

    private func authoritativeArchiveFormat() throws -> ArchiveFormat {
        try ArchiveFormat(archiveRoot: authoritativeArchiveRoot())
    }

    private static let hasAuthoritativeArchive: Bool = {
        FileManager.default.fileExists(atPath: authoritativeArchiveRoot().path)
    }()

    private static func authoritativeArchiveRoot() -> URL {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        // The package now lives at OmenArchive/OmenArchiveKit. Its parent is
        // the archive root used by integration fixtures and descriptor parity.
        return packageRoot.deletingLastPathComponent()
    }

    private func authoritativeArchiveRoot() -> URL {
        Self.authoritativeArchiveRoot()
    }

    private func validateFixture(named name: String) throws -> ArchiveValidationReport {
        let fileManager = FileManager.default
        let fixtureRoot = fileManager.temporaryDirectory
            .appendingPathComponent("omen-archive-fixture-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: fixtureRoot) }

        let archiveRoot = authoritativeArchiveRoot()
        let sourceFixture = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/validator")
            .appendingPathComponent(name)
        try fileManager.createDirectory(at: fixtureRoot, withIntermediateDirectories: true)
        try fileManager.copyItem(
            at: sourceFixture.appendingPathComponent("src"),
            to: fixtureRoot.appendingPathComponent("src")
        )
        try fileManager.copyItem(
            at: archiveRoot.appendingPathComponent("schemas"),
            to: fixtureRoot.appendingPathComponent("schemas")
        )
        try fileManager.copyItem(
            at: archiveRoot.appendingPathComponent("mechanics"),
            to: fixtureRoot.appendingPathComponent("mechanics")
        )
        if name == "valid-feat" {
            let path = fixtureRoot.appendingPathComponent("src/test-book/feat/power-attack.yml")
            var lines = try String(contentsOf: path, encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            if let start = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "- inputName: target" }) {
                var end = start
                while end < lines.count,
                      !lines[end].trimmingCharacters(in: .whitespaces).hasPrefix("startLevel:") {
                    end += 1
                }
                lines.replaceSubrange(start..<end, with: [
                    "      - inputName: selectionId",
                    "        expectedValue:",
                    "          valueTypeID: org.openomen.pf2e.core/value/uuid",
                    "          source:",
                    "            kind: literal",
                    "            value:",
                    "              typeID: org.openomen.pf2e.core/value/uuid",
                    "              revision: 1",
                    "              payload: 00000000-0000-4000-8000-000000000001",
                    "      - inputName: featId",
                    "        expectedValue:",
                    "          valueTypeID: org.openomen.pf2e.core/value/feat-id",
                    "          source:",
                    "            kind: literal",
                    "            value:",
                    "              typeID: org.openomen.pf2e.core/value/feat-id",
                    "              revision: 1",
                    "              payload: 00000000-0000-4000-8000-000000000001"
                ])
                try lines.joined(separator: "\n").write(to: path, atomically: true, encoding: .utf8)
            }
        }
        return try ArchiveValidator(format: ArchiveFormat(archiveRoot: fixtureRoot)).validateAll()
    }
}
