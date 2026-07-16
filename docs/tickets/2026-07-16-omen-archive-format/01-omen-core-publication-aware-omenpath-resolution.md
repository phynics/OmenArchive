# 01 — Add publication-aware OmenPath resolution

**Repository:** `OmenCore`
**Priority:** Foundation
**Blocks:** 04, 07, 08, 09

## Goal

Make `OmenPath` resolve a logical resource across every available publication without losing source qualification. `omen://feat/group-impression` must return every matching version; consumers that need one resource use the newest publication by default. `?source=<publication-id>` narrows the result.

## Context

`CharacterResourceResolver.resolve(omenPath:)` already returns an array, but `OmenPath.toRecordDescriptor()` currently discards the `source` query. `ResourceFilterComponent` has no publication predicate, and resource metadata does not provide a reliable published-date ordering field.

Publication context is metadata inheritance only. It must not implicitly qualify an authored OmenPath. An unqualified path remains global.

## Scope

- Add publication ID and publication date to runtime resource metadata (`ResourceTag` or its contained source representation).
- Add a source/publication filter component and Codable support.
- Preserve the OmenPath `source` query while building `RecordDescriptor` values.
- Sort OmenPath resolver results by publication date descending, then publication ID ascending.
- Leave resolver return type array-valued. Do not select, deduplicate, or hide versions in this API.

## Non-goals

- Do not introduce broad OmenPath query/filter syntax.
- Do not change archive YAML in this ticket.
- Do not make an unqualified OmenPath source-scoped by the caller’s publication.

## Likely files

- `Sources/OmenCore/Utility/ResourceTag.swift`
- `Sources/OmenCore/RecordResolver/ResourceFilter/ResourceFilterComponent.swift`
- `Sources/OmenCore/RecordResolver/ResourceFilter/ResourceFilter+Codable.swift`
- `Sources/OmenCore/RecordResolver/OmenPath+RecordDescriptor.swift`
- `Sources/OmenCore/RecordResolver/CharacterResourceResolver.swift`
- `Sources/OmenURI/OmenURI.swift`
- `Tests/OmenURITests/OmenPathRecordDescriptorTests.swift`
- `Tests/OmenCoreTests/RecordDescriptorTests.swift`

## Acceptance criteria

- `omen://feat/group-impression` resolves all loaded resources whose canonical feat name is `group-impression`.
- `omen://feat/group-impression?source=paizo-pathfinder-player-core` resolves only resources from that publication.
- Returned arrays are newest publication first; equal dates use publication ID as a stable tie-breaker.
- Existing list paths such as `omen://feat` retain their list semantics.
- Source query information survives parsing, descriptor generation, Codable round trips, and filtering.
- Tests cover zero, one, and multiple versions, including tied publication dates.

## Verification

```bash
swift test --package-path OmenCore --filter OmenPathRecordDescriptorTests
swift test --package-path OmenCore --filter RecordDescriptorTests
swift test --package-path OmenCore
```
