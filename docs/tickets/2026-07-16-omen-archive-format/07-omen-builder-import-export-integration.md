# 07 — Route OmenBuilder archive import, export, and editor through OmenTome

**Repository:** `OmenBuilder`
**Priority:** Integration
**Depends on:** 01–06
**Blocks:** 08, 09

## Goal

Make OmenBuilder use OmenTome as its only archive-format boundary. Import must validate an entire workspace before persistence; export must stage, validate, and only then replace the destination. Bridges convert author concepts to OmenCore and back.

## Import behavior

1. Open/index/validate the incoming archive workspace.
2. Resolve fixed references and validate choices against current and incoming resources.
3. Lower author DTOs to OmenCore records/effects.
4. Persist the incoming publication in one transaction only after all diagnostics are clean.

No partial import may remain after a failure.

## Export behavior

1. Raise OmenCore/Foundry records into OmenTome author DTOs.
2. Reverse-resolve UUID resource values to qualified OmenPaths.
3. Derive stable rule/choice names when the source has only runtime UUIDs.
4. Write a staging archive, canonicalize it, and validate it.
5. Replace the requested destination only after staged validation succeeds.

## Scope

- Remove direct `TomeCoder.decode`/`encode` archive paths from loaders, adapters, writer, browser validation, and AI staging.
- Update OmenTome-to-OmenCore rule conversion for deterministic IDs, source-aware references, requirement trees, and choice policies.
- Preserve raw-editor text on normal saves while validating it through OmenTome.

## Likely files

- `OmenScribe/DataStores/OmenArchive/OmenArchiveLoaders.swift`
- `OmenScribe/DataStores/OmenArchive/PublicationPackage.swift`
- `OmenScribe/DataStores/OmenArchive/OmenDBImporter.swift`
- `OmenScribe/DataStores/SwiftData/OmenTomeExtensions/CharacterRule+OmenCore.swift`
- `OmenScribe/DataStores/SwiftData/OmenTomeExtensions/OmenTome+ConversionExtensions.swift`
- Foundry archive adapter/store files
- `OmenScribe/Services/OmenArchive/OmenArchiveWriter.swift`
- `OmenScribe/Services/OmenArchive/Browser/OABFileBrowser.swift`
- `OmenScribe/Features/Workspace/Staging/AIEffectsApplier.swift`
- Archive loading, bridge, and configuration tests

## Acceptance criteria

- Complete migrated archive import succeeds.
- Invalid import rolls back all writes for its publication.
- Export failure leaves pre-existing destination files untouched.
- Exported resource references are source-qualified OmenPaths.
- Export/re-import yields equivalent OmenCore records and rules.
- Browser validation uses OmenTome diagnostics without reformatting author text.

## Verification

Run focused macOS archive loading, bridge, and configuration suites, then the complete OmenBuilder test target available in the repository. Also run an end-to-end temporary-directory export/re-import test.
