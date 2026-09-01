import Foundation
import Testing
@testable import OmenArchiveKit

/// Keeps the Swift validator's diagnostics aligned with the committed fixture
/// outcomes. The fixture roots are
/// deliberately copied into a temporary archive so each case exercises the
/// same public `ArchiveFormat(archiveRoot:)` and `ArchiveValidator` seam that
/// CI and OmenScribe will use.
@Suite("Archive validator parity fixtures")
struct ValidatorParityTests {
    @Test("accepts the committed valid fixture set")
    func acceptsValidFixtures() throws {
        try validateFixture("valid-background", path: "src/test-book/background/scholar.yml")
        try validateFixture("valid-domain", path: "src/test-book/domain/air.yml")
        try validateFixture("valid-companion", path: "src/test-book/companion/test-companion.yml")
        try validateFixture("valid-class", path: "src/test-book/class/fighter/fighter.yml")
        try validateFixture("valid-school", path: "src/test-book/class/wizard/schools/battle-magic.yml")
        try validateFixture("valid-feat", path: "src/test-book/feat/power-attack.yml")
    }

    @Test("accepts archetype bundles with feat children")
    func acceptsArchetypeBundle() throws {
        try validateFixture(
            "valid-archetype",
            path: "src/test-book/archetype/test-archetype/test-archetype.yml"
        )
        try validateFixture(
            "valid-archetype",
            path: "src/test-book/archetype/test-archetype/feats/test-dedication.yml"
        )
    }

    @Test("reports duplicate background variants")
    func duplicateBackgroundVariant() throws {
        let message = try validationMessage(
            fixture: "invalid-duplicate-background-variant-key",
            path: "src/test-book/background/scholar.yml"
        )
        #expect(message.contains("variant key arcana is duplicated"))
    }

    @Test("reports schema type failures with the data path")
    func schemaTypeFailure() throws {
        let message = try validationMessage(
            fixture: "invalid-schema",
            path: "src/test-book/background/trickster.yml"
        )
        #expect(message.contains("$.skillOption"))
    }

    @Test("reports missing source.book")
    func missingSourceBook() throws {
        let message = try validationMessage(
            fixture: "invalid-missing-book",
            path: "src/test-book/action/aid.yml"
        )
        #expect(message.contains("source.book"))
    }

    @Test("validates unsaved editor text through the file-backed seam")
    func inMemoryText() throws {
        let root = try makeArchiveRoot(fixture: "valid-background")
        defer { try? FileManager.default.removeItem(at: root) }
        let path = "src/test-book/background/scholar.yml"
        let text = try String(
            contentsOf: root.appendingPathComponent(path),
            encoding: .utf8
        )

        try ArchiveValidator(format: try ArchiveFormat(archiveRoot: root))
            .validate(text: text, relativePath: path)
    }

    @Test("reports filename and heritage ancestry mismatches together")
    func nameAndHeritageMismatch() throws {
        let message = try validationMessage(
            fixture: "invalid-name-and-heritage",
            path: "src/test-book/heritage/elf/not-seer-elf.yml"
        )
        #expect(message.contains("filename slug"))
        #expect(message.contains("heritage ancestry"))
    }

    @Test("rejects UTF-16 authored files as non-UTF-8")
    func invalidUTF16() throws {
        let message = try validationMessage(
            fixture: "invalid-utf16",
            path: "src/test-book/action/aid.yml"
        )
        #expect(message.contains("UTF-8"))
    }

    @Test("rejects unsupported and unsafe archive paths")
    func invalidPaths() throws {
        let root = try makeArchiveRoot(fixture: "valid-background")
        defer { try? FileManager.default.removeItem(at: root) }
        let format = try ArchiveFormat(archiveRoot: root)

        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/unknown/item.yml")) {
            try format.classify("src/test-book/unknown/item.yml")
        }
        #expect(throws: ArchiveFormatError.invalidPath("../src/test-book/background/scholar.yml")) {
            try format.classify("../src/test-book/background/scholar.yml")
        }
        #expect(throws: ArchiveFormatError.invalidPath("src//test-book/background/scholar.yml")) {
            try format.classify("src//test-book/background/scholar.yml")
        }
        #expect(throws: ArchiveFormatError.unsupportedPath("src/test-book/background/scholar.yaml")) {
            try format.classify("src/test-book/background/scholar.yaml")
        }
    }

    @Test("validates declared custom class children")
    func customClassChild() throws {
        try validateFixture(
            "valid-class",
            path: "src/test-book/class/fighter/fighter.yml"
        )

        let root = try makeArchiveRoot(fixture: "valid-class")
        defer { try? FileManager.default.removeItem(at: root) }
        let child = root
            .appendingPathComponent("src/test-book/class/ranger/hunters-edge", isDirectory: true)
            .appendingPathComponent("custom-feature.yml")
        try FileManager.default.createDirectory(at: child.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(
            """
            name: custom feature
            source:
              publisher: paizo
              book: Test Book
            description: |
              A custom class-owned feature.
            """.utf8
        ).write(to: child)

        let validator = ArchiveValidator(format: try ArchiveFormat(archiveRoot: root))
        try validator.validate("src/test-book/class/ranger/hunters-edge/custom-feature.yml")
    }

    @Test("reports unknown effects in the complete validation report")
    func unknownEffectIsReportedByFullValidator() throws {
        let root = try makeArchiveRoot(fixture: "valid-feat")
        defer { try? FileManager.default.removeItem(at: root) }

        let path = "src/test-book/feat/power-attack.yml"
        let file = root.appendingPathComponent(path)
        let text = try String(contentsOf: file, encoding: .utf8)
            .replacingOccurrences(
                of: "org.openomen.pf2e.core/effect/add-feat",
                with: "org.example.missing/effect/not-registered"
            )
        try text.write(to: file, atomically: true, encoding: .utf8)

        let report = try ArchiveValidator(format: try ArchiveFormat(archiveRoot: root)).validateAll()
        #expect(!report.isValid)
        #expect(report.diagnostics.isEmpty)
        #expect(report.mechanicsDiagnostics.count == 1)
        #expect(report.mechanicsDiagnostics.first?.relativePath == path)
        #expect(report.mechanicsDiagnostics.first?.kind == .unknownEffect)

        let encoded = try JSONEncoder().encode(report)
        #expect(try JSONDecoder().decode(ArchiveValidationReport.self, from: encoded) == report)
    }

    @Test("reports same-file structural and mechanics diagnostics")
    func sameFileMixedDefectsAreReportedByFullValidator() throws {
        let root = try makeArchiveRoot(fixture: "valid-feat")
        defer { try? FileManager.default.removeItem(at: root) }

        let path = "src/test-book/feat/power-attack.yml"
        let file = root.appendingPathComponent(path)
        let text = try String(contentsOf: file, encoding: .utf8)
            .replacingOccurrences(of: "name: power attack", with: "name: Power Attack")
            .replacingOccurrences(
                of: "org.openomen.pf2e.core/effect/add-feat",
                with: "org.example.missing/effect/not-registered"
            )
        try text.write(to: file, atomically: true, encoding: .utf8)

        let report = try ArchiveValidator(format: try ArchiveFormat(archiveRoot: root)).validateAll()
        #expect(report.diagnostics.contains { diagnostic in
            diagnostic.relativePath == path && diagnostic.message.contains("must be lowercase")
        })
        #expect(report.mechanicsDiagnostics.contains { diagnostic in
            diagnostic.relativePath == path && diagnostic.kind == .unknownEffect
        })
    }

    @Test("reports a wrong registered-value revision through the complete validator")
    func wrongValueRevisionIsReportedByFullValidator() throws {
        let root = try makeArchiveRoot(fixture: "valid-feat")
        defer { try? FileManager.default.removeItem(at: root) }
        let path = "src/test-book/feat/power-attack.yml"
        let file = root.appendingPathComponent(path)
        var text = try String(contentsOf: file, encoding: .utf8)
        text = text.replacingOccurrences(
            of: "typeID: org.openomen.pf2e.core/value/uuid\n              revision: 1",
            with: "typeID: org.openomen.pf2e.core/value/uuid\n              revision: 2"
        )
        try text.write(to: file, atomically: true, encoding: .utf8)

        let report = try ArchiveValidator(format: try ArchiveFormat(archiveRoot: root)).validateAll()
        #expect(report.diagnostics.isEmpty)
        #expect(report.mechanicsDiagnostics.map(\.kind) == [.invalidLiteral])
        #expect(report.mechanicsDiagnostics.first?.relativePath == path)
    }

    @Test("reports malformed registered-value payloads through the complete validator")
    func malformedValueIsReportedByFullValidator() throws {
        let root = try makeArchiveRoot(fixture: "valid-feat")
        defer { try? FileManager.default.removeItem(at: root) }
        let path = "src/test-book/feat/power-attack.yml"
        let file = root.appendingPathComponent(path)
        var text = try String(contentsOf: file, encoding: .utf8)
        text = text.replacingOccurrences(
            of: "payload: 00000000-0000-4000-8000-000000000001",
            with: "payload:\n                malformed: true"
        )
        try text.write(to: file, atomically: true, encoding: .utf8)

        let report = try ArchiveValidator(format: try ArchiveFormat(archiveRoot: root)).validateAll()
        #expect(report.diagnostics.isEmpty)
        #expect(report.mechanicsDiagnostics.map(\.kind) == [.invalidLiteral, .invalidLiteral])
        #expect(Set(report.mechanicsDiagnostics.map(\.relativePath)) == [path])
    }

    @Test("reports missing publication modules through the complete validator")
    func missingModuleIsReportedByFullValidator() throws {
        let root = try makeArchiveRoot(fixture: "valid-feat")
        defer { try? FileManager.default.removeItem(at: root) }
        let path = "src/test-book/publication.yml"
        let file = root.appendingPathComponent(path)
        let text = """
        id: test-book
        publisher: test
        title: Test Book
        published: "2026-01-01"
        mechanicsModules:
          - moduleID: org.example.missing
            revision: 1
        """
        try text.write(to: file, atomically: true, encoding: .utf8)

        let report = try ArchiveValidator(format: try ArchiveFormat(archiveRoot: root)).validateAll()
        #expect(report.diagnostics.isEmpty)
        #expect(report.mechanicsDiagnostics.map(\.kind) == [.unresolvedDependency])
        #expect(report.mechanicsDiagnostics.first?.relativePath == path)
    }

    private func validateFixture(_ fixture: String, path: String) throws {
        let root = try makeArchiveRoot(fixture: fixture)
        defer { try? FileManager.default.removeItem(at: root) }
        let validator = ArchiveValidator(format: try ArchiveFormat(archiveRoot: root))
        try validator.validate(path)
    }

    private func validationMessage(fixture: String, path: String) throws -> String {
        let root = try makeArchiveRoot(fixture: fixture)
        defer { try? FileManager.default.removeItem(at: root) }
        let validator = ArchiveValidator(format: try ArchiveFormat(archiveRoot: root))
        do {
            try validator.validate(path)
            Issue.record("Expected fixture to fail validation: \(fixture)")
            return ""
        } catch {
            return String(describing: error)
        }
    }

    private func makeArchiveRoot(fixture: String) throws -> URL {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory
            .appendingPathComponent("omen-validator-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)

        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let archiveRoot = packageRoot.deletingLastPathComponent()
        try fileManager.copyItem(
            at: archiveRoot.appendingPathComponent("schemas", isDirectory: true),
            to: root.appendingPathComponent("schemas", isDirectory: true)
        )
        try fileManager.copyItem(
            at: archiveRoot.appendingPathComponent("mechanics", isDirectory: true),
            to: root.appendingPathComponent("mechanics", isDirectory: true)
        )
        try fileManager.copyItem(
            at: archiveRoot
                .appendingPathComponent("tests/fixtures/validator", isDirectory: true)
                .appendingPathComponent(fixture, isDirectory: true)
                .appendingPathComponent("src", isDirectory: true),
            to: root.appendingPathComponent("src", isDirectory: true)
        )
        if fixture == "valid-feat" {
            let path = root.appendingPathComponent("src/test-book/feat/power-attack.yml")
            var text = try String(contentsOf: path, encoding: .utf8)
            var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
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
                text = lines.joined(separator: "\n")
            }
            try text.write(to: path, atomically: true, encoding: .utf8)
        }
        return root
    }
}
