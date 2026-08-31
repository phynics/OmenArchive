import Foundation
#if canImport(OmenCoreMechanics) && canImport(OmenSpellcastingMechanics)
import OmenCoreMechanics
#endif
import OmenMechanics
#if canImport(OmenCoreMechanics) && canImport(OmenSpellcastingMechanics)
import OmenSpellcastingMechanics
#endif
import Testing
@testable import OmenArchiveKit

@Suite("Archive mechanics contracts")
struct ArchiveMechanicsTests {
    private let moduleID = try! MechanicsModuleID("org.example.core")
    private let stringID = try! ValueTypeID("org.example.core/value/string")
    private let effectID = try! EffectKindID("org.example.core/effect/set-name")
    private let unknownEffectID = try! EffectKindID("org.example.other/effect/not-registered")

    private func document(
        moduleID: MechanicsModuleID? = nil,
        dependencies: [MechanicsModuleDependency] = []
    ) throws -> ArchiveMechanicsDocument {
        let descriptor = MechanicsModuleDescriptor(
            moduleID: moduleID ?? self.moduleID,
            dependencies: dependencies,
            valueTypes: [MechanicsValueTypeDescriptor(typeID: stringID, schema: .string)],
            effects: [EffectWire(
                reference: EffectReference(kindID: effectID),
                inputDescriptors: [EffectInputDescriptor(name: "name", valueTypeID: stringID)]
            )]
        )
        return ArchiveMechanicsDocument(
            relativePath: "mechanics/\(descriptor.moduleID.rawValue).json",
            rawData: try descriptor.canonicalJSONData,
            descriptor: descriptor
        )
    }

    private func rule(valueRevision: Int = 1) throws -> [String: Any] {
        let value = try RegisteredValue(typeID: stringID, revision: valueRevision, payload: .string("ok"))
        return [
            "effectReference": ["kindID": effectID.rawValue, "revision": 1],
            "inputRecipes": [[
                "inputName": "name",
                "expectedValue": [
                    "valueTypeID": stringID.rawValue,
                    "source": [
                        "kind": "literal",
                        "value": [
                            "typeID": value.typeID.rawValue,
                            "revision": value.revision,
                            "payload": "ok"
                        ]
                    ]
                ]
            ]]
        ]
    }

    private func unknownEffectRule() -> [String: Any] {
        [
            "effectReference": ["kindID": unknownEffectID.rawValue, "revision": 1],
            "inputRecipes": []
        ]
    }

    private func malformedRegisteredValueRule() -> [String: Any] {
        [
            "effectReference": ["kindID": effectID.rawValue, "revision": 1],
            "inputRecipes": [[
                "inputName": "name",
                "expectedValue": [
                    "valueTypeID": stringID.rawValue,
                    "source": [
                        "kind": "literal",
                        "value": [
                            "typeID": stringID.rawValue,
                            "revision": 1,
                            // This is valid JSON but not a payload accepted by
                            // the registered string value type.
                            "payload": ["unexpected": "object"]
                        ]
                    ]
                ]
            ]]
        ]
    }

    @Test("reports unresolved dependencies without discarding descriptors")
    func unresolvedDependencyIsStructured() throws {
        let missing = try MechanicsModuleID("org.example.missing")
        let catalog = ArchiveMechanicsCatalog(documents: [try document(
            dependencies: [MechanicsModuleDependency(moduleID: missing, revision: 2)]
        )])

        let report = catalog.validate()
        #expect(report.diagnostics.contains { $0.kind == .unresolvedDependency })
        #expect(catalog.descriptors.count == 1)
    }

    @Test("rejects an effect from an undeclared mechanics module")
    func unknownEffectIsStructured() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])
        let diagnostics = catalog.validateRules(
            in: ["rules": [unknownEffectRule()]],
            relativePath: "src/book/feat/unknown.yml"
        )

        #expect(diagnostics == [ArchiveMechanicsDiagnostic(
            relativePath: "src/book/feat/unknown.yml",
            kind: .unknownEffect,
            message: "Effect \(unknownEffectID) is not declared by a discovered mechanics module."
        )])
    }

    @Test("requires descriptor filename to match its module ID")
    func descriptorPathIdentity() throws {
        let descriptor = try document()
        let renamed = ArchiveMechanicsDocument(
            relativePath: "mechanics/other.json",
            rawData: descriptor.rawData,
            descriptor: descriptor.descriptor
        )

        let report = ArchiveMechanicsCatalog(documents: [renamed]).validate()
        #expect(report.diagnostics.contains { $0.kind == .pathIdentityMismatch })
    }

    @Test("validates canonical rule input order and registered literal schema")
    func canonicalRuleContract() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])

        let diagnostics = catalog.validateRules(in: ["rules": [try rule()]], relativePath: "src/book/feat/example.yml")
        #expect(diagnostics.isEmpty)
    }

    @Test("requires registered value revisions to match the descriptor")
    func registeredValueRevisionMustMatch() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])
        let diagnostics = catalog.validateRules(
            in: ["rules": [try rule(valueRevision: 2)]],
            relativePath: "src/book/feat/example.yml"
        )
        #expect(diagnostics.contains { $0.kind == .invalidLiteral })
    }

    @Test("rejects malformed registered value payloads")
    func malformedRegisteredValueIsStructured() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])
        let path = "src/book/feat/malformed.yml"
        let diagnostics = catalog.validateRules(
            in: ["rules": [malformedRegisteredValueRule()]],
            relativePath: path
        )

        #expect(diagnostics == [ArchiveMechanicsDiagnostic(
            relativePath: path,
            kind: .invalidLiteral,
            message: "Effect \(effectID) input name contains a literal outside its registered value schema."
        )])
    }

    @Test("round-trips negative validation reports as structured data")
    func negativeReportRoundTrip() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])
        let path = "src/book/feat/unknown.yml"
        let report = ArchiveMechanicsValidationReport(
            documentsValidated: catalog.documents.count,
            diagnostics: catalog.validateRules(
                in: ["rules": [unknownEffectRule()]],
                relativePath: path
            )
        )

        let encoded = try JSONEncoder().encode(report)
        let decoded = try JSONDecoder().decode(ArchiveMechanicsValidationReport.self, from: encoded)
        #expect(decoded == report)
        #expect(decoded.documentsValidated == 1)
        #expect(decoded.diagnostics.first?.relativePath == path)
        #expect(decoded.diagnostics.first?.kind == .unknownEffect)
    }

    @Test("rejects nested effect references")
    func nestedEffectReferenceIsRejected() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])
        let diagnostics = catalog.validateRules(
            in: ["rules": [["effect": ["reference": ["kindID": effectID.rawValue, "revision": 1]]]]],
            relativePath: "src/book/feat/example.yml"
        )
        #expect(diagnostics.contains { $0.kind == .unknownEffect })
    }

    @Test("rejects legacy effect templates as a clean-break diagnostic")
    func legacyEffectTemplateIsRejected() throws {
        let catalog = ArchiveMechanicsCatalog(documents: [try document()])
        let diagnostics = catalog.validateRules(
            in: ["rules": [["effectTemplate": ["kind": "set-name"]]]],
            relativePath: "src/book/feat/example.yml"
        )
        #expect(diagnostics.contains { $0.kind == .unknownEffect })
    }

    @Test("reports malformed publication module dependencies")
    func malformedPublicationDependencyIsStructured() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("archive-mechanics-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("schemas"), withIntermediateDirectories: true
        )
        let manifest = ArchiveFormatManifest(
            version: 1,
            publication: .init(path: "src/{publication}/publication.yml", schema: "publication.schema.json"),
            families: [.init(id: "feat", directory: "feat", layout: .flat, schema: "feat.json")]
        )
        try JSONEncoder().encode(manifest).write(
            to: root.appendingPathComponent("schemas/archive-format.json")
        )
        try Data("{}".utf8).write(to: root.appendingPathComponent("schemas/feat.json"))
        try Data("{}".utf8).write(to: root.appendingPathComponent("schemas/publication.schema.json"))
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("src/test-book"), withIntermediateDirectories: true
        )
        let publication = """
        id: test-book
        mechanicsModules:
        - moduleID: org.example.core
        """
        try publication.write(
            to: root.appendingPathComponent("src/test-book/publication.yml"),
            atomically: true,
            encoding: .utf8
        )
        let loader = ArchiveMechanicsLoader(format: try ArchiveFormat(archiveRoot: root))
        let diagnostics = try loader.publicationDependencyDiagnostics()
        #expect(diagnostics.count == 1)
        #expect(diagnostics.first?.kind == .malformedDependency)
    }

    #if canImport(OmenCoreMechanics) && canImport(OmenSpellcastingMechanics)
    @Test("committed mechanics descriptors match their Swift modules")
    func committedDescriptorParity() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let archiveRoot = packageRoot.deletingLastPathComponent()
        let format = try ArchiveFormat(archiveRoot: archiveRoot)
        let documents = try ArchiveMechanicsLoader(format: format).discover()
        #expect(!documents.isEmpty)
        let committedURL = archiveRoot.appendingPathComponent(
            "mechanics/org.openomen.pf2e.core.json"
        )
        var expectedBytes = try PF2ECoreMechanics.module().descriptor.canonicalJSONData
        expectedBytes.append(0x0A)
        let committedBytes = try Data(contentsOf: committedURL)
        #expect(committedBytes == expectedBytes)

        let spellcastingURL = archiveRoot.appendingPathComponent(
            "mechanics/org.openomen.pf2e.spellcasting.json"
        )
        var expectedSpellcastingBytes = try PF2ESpellcastingMechanics.module().descriptor.canonicalJSONData
        expectedSpellcastingBytes.append(0x0A)
        #expect(try Data(contentsOf: spellcastingURL) == expectedSpellcastingBytes)
        for document in documents {
            guard let descriptor = document.descriptor else { continue }
            let canonical = try descriptor.canonicalJSONData
            let decoded = try JSONDecoder().decode(MechanicsModuleDescriptor.self, from: canonical)
            #expect(decoded == descriptor)
        }
    }
    #endif
}
