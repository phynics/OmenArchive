# 04 — Deepen OmenTome into the archive-format module

**Repository:** `OmenBuilder`
**Priority:** Foundation
**Depends on:** 01 semantics
**Blocks:** 05, 06, 07, 08

## Goal

Repurpose the existing OmenTome package as the single semantic owner of the human archive format. It must understand archive directories, publication manifests, OmenPaths, cross-file references, formatting, schemas, and diagnostics without importing OmenCore internals.

## Design

OmenTome depends on Yams and `OmenURI`, not `OmenCore`. OmenScribe remains responsible for lowering author resources into OmenCore and raising OmenCore/Foundry records for export.

The target API should be context-specific rather than generic `Codable` plumbing:

```swift
ArchiveWorkspace.open(at:)
ArchiveCodec.decodeResource(at:in:)
ArchiveCodec.encodeResource(_:in:)
ArchiveValidator.validate(_:)
```

## Scope

- Add `PublicationManifest` with required `id`, `publisher`, `title`, and `published`.
- Derive resource type, publication, and canonical slug from a resource path.
- Apply publication metadata inheritance; allow only resource-local source fields such as page.
- Build an archive-wide index of logical resources and publication versions.
- Decode with unknown-key rejection and diagnostics containing file path, field path, and YAML location when possible.
- Replace `TomeCoder` as the public archive boundary; compatibility aliases must be removed by the final format migration.

## Likely files

- `OmenTome/Package.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ArchiveWorkspace.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ArchiveResource.swift`
- Create `OmenTome/Sources/OmenTome/Archive/PublicationManifest.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ArchiveCodec.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ArchiveDiagnostic.swift`
- Modify `OmenTome/Sources/OmenTome/TomeCoder.swift`
- Create `OmenTome/Tests/OmenTomeTests/ArchiveWorkspaceTests.swift`

## Acceptance criteria

- Opening an archive finds every manifest and resource, produces a logical-resource index, and orders versions by publication date.
- Source-qualified paths filter versions; unqualified paths remain global.
- Mismatched path/type/slug, missing manifest fields, unknown YAML keys, and invalid OmenPaths are diagnostics rather than crashes.
- OmenTome does not import OmenCore.
- Tests cover manifest inheritance, missing resources, tie ordering, and path-derived identity.

## Verification

```bash
swift test --package-path OmenTome
```
