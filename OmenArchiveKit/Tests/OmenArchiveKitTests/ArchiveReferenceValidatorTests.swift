import Foundation
import OmenURI
import Testing
@testable import OmenArchiveKit

@Suite("Archive reference validation")
struct ArchiveReferenceValidatorTests {
    private let format: ArchiveFormat

    init() throws {
        let fixtureURL = Bundle.module.url(forResource: "archive-format", withExtension: "json")!
        let manifest = try JSONDecoder().decode(
            ArchiveFormatManifest.self,
            from: Data(contentsOf: fixtureURL)
        )
        format = try ArchiveFormat(manifest: manifest)
    }

    @Test("extracts nested OmenPath references")
    func extractsNestedReferences() {
        let value: [String: Any] = [
            "one": "omen://feat/power-attack",
            "nested": ["omen://spell/fireball", "plain text"]
        ]

        #expect(
            Set(ArchiveReferenceValidator.referenceValues(in: value))
                == ["omen://feat/power-attack", "omen://spell/fireball"]
        )
    }

    @Test("reports malformed, dangling, and ambiguous references")
    func reportsReferenceKinds() throws {
        let validator = ArchiveReferenceValidator(format: format) { path in
            switch path.url.absoluteString {
            case "omen://feat/power-attack":
                return [ArchiveReferenceTarget(relativePath: "src/test-book/feat/power-attack.yml")]
            case "omen://feat/ambiguous":
                return [
                    ArchiveReferenceTarget(relativePath: "src/one/feat/ambiguous.yml"),
                    ArchiveReferenceTarget(relativePath: "src/two/feat/ambiguous.yml")
                ]
            default:
                return []
            }
        }

        let malformed = try validator.validate(
            rawValue: "not-an-omen-path",
            relativePath: "src/test-book/feat/example.yml"
        )
        let dangling = try validator.validate(
            rawValue: "omen://feat/missing",
            relativePath: "src/test-book/feat/example.yml"
        )
        let ambiguous = try validator.validate(
            rawValue: "omen://feat/ambiguous",
            relativePath: "src/test-book/feat/example.yml"
        )

        #expect(malformed.first?.kind == .malformed)
        #expect(malformed.first?.severity == .error)
        #expect(dangling.first?.kind == .dangling)
        #expect(dangling.first?.severity == .error)
        #expect(ambiguous.first?.kind == .ambiguous)
        #expect(ambiguous.first?.severity == .warning)
    }

    @Test("validates editor text without requiring a filesystem root")
    func validatesText() throws {
        let validator = ArchiveReferenceValidator(format: format) { path in
            guard path.url.absoluteString == "omen://feat/power-attack" else { return [] }
            return [ArchiveReferenceTarget(relativePath: "src/test-book/feat/power-attack.yml")]
        }

        let issues = try validator.validate(
            text: "rule: omen://feat/power-attack\n",
            relativePath: "src/test-book/feat/example.yml"
        )

        #expect(issues.isEmpty)
    }
}
