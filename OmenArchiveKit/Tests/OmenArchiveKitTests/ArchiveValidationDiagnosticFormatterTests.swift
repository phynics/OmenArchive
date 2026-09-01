import Testing
@testable import OmenArchiveKit

@Suite("Archive validation diagnostic formatting")
struct ArchiveValidationDiagnosticFormatterTests {
    @Test("formats structural diagnostics")
    func structuralDiagnostics() {
        let report = ArchiveValidationReport(
            filesValidated: 1,
            diagnostics: [
                .init(relativePath: "src/book/feat/example.yml", message: "name is invalid")
            ]
        )

        #expect(
            ArchiveValidationDiagnosticFormatter.lines(for: report)
                == ["src/book/feat/example.yml: name is invalid"]
        )
        #expect(
            ArchiveValidationDiagnosticFormatter.format(report)
                == "src/book/feat/example.yml: name is invalid"
        )
    }

    @Test("formats mechanics diagnostics")
    func mechanicsDiagnostics() {
        let report = ArchiveValidationReport(
            filesValidated: 0,
            diagnostics: [],
            mechanicsDiagnostics: [
                .init(
                    relativePath: "mechanics/org.example.core.json",
                    moduleID: "org.example.core",
                    kind: .unresolvedDependency,
                    message: "Module requires org.example.missing."
                )
            ]
        )

        #expect(
            ArchiveValidationDiagnosticFormatter.lines(for: report)
                == [
                    "mechanics/org.example.core.json: mechanics [unresolvedDependency] Module requires org.example.missing."
                ]
        )
    }

    @Test("keeps structural and mechanics diagnostics in one report")
    func mixedDiagnostics() {
        let report = ArchiveValidationReport(
            filesValidated: 2,
            diagnostics: [
                .init(relativePath: "src/book/publication.yml", message: "publication is invalid")
            ],
            mechanicsDiagnostics: [
                .init(
                    relativePath: "src/book/feat/example.yml",
                    kind: .unknownEffect,
                    message: "Effect is not registered."
                )
            ]
        )

        #expect(
            ArchiveValidationDiagnosticFormatter.format(report)
                == "src/book/publication.yml: publication is invalid\n"
                    + "src/book/feat/example.yml: mechanics [unknownEffect] Effect is not registered."
        )
    }
}
