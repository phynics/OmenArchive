# Omen Archive Format Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the legacy archive YAML with a human-authored, OmenPath-based format that is semantically owned by OmenTome and can round-trip through OmenBuilder.

**Architecture:** OmenTome becomes the author-format module and CLI. It owns manifests, path-derived identities, the archive AST, formatting, schemas, cross-file validation, OmenPath validation, rule/choice syntax, and diagnostics. OmenScribe bridges validated author resources to and from OmenCore; OmenCore owns runtime resolution, rule application, selections, and persistence.

**Tech Stack:** Swift 6, SwiftPM, Yams, OmenURI, OmenCore, OmenBuilder/OmenScribe, OmenArchive YAML, GitHub Actions.

## Global Constraints

- Flag day: migrate all 423 current archive resources; remove legacy parsing and schemas after migration.
- Generated fixed resource references are source-qualified OmenPaths.
- `omen://feat/group-impression` is a logical-resource path, not a broad filter: resolution returns all versions ordered by publication date, newest first; fixed consumers use the newest unless a source is specified.
- Each `src/<publication>/publication.yml` provides `id`, `publisher`, `title`, and `published`; resource files inherit this metadata and may specify only `source.page`.
- Resource path supplies resource kind and slug; resource `name` is presentation text.
- YAML keys use `snake_case`; unknown keys are errors; defaults, empty values, and internal-template fields are not authored.
- Rules use local `name` values; OmenCore rule UUIDs are deterministically derived from qualified owner OmenPath plus rule name.
- Choices default to exactly one value, enforce candidate requirements, exclude owned resources, and prohibit duplicate selections. `count`, `allow.unmet_requirements`, `allow.already_owned`, and `allow.duplicates` are explicit opt-ins.
- Rule requirements and choice matching share recursive `all` / `any` / `not` syntax, with context-appropriate leaves.
- Import writes are transactional; export writes stage and validate before replacing output.

## Approved Authoring Examples

```yaml
# src/paizo-pathfinder-player-core/publication.yml
id: paizo-pathfinder-player-core
publisher: Paizo
title: Pathfinder Player Core
published: 2023-11-15
```

```yaml
# src/paizo-pathfinder-player-core/background/barrister.yml
name: Barrister
boosts:
  - choose: [intelligence, charisma]
  - free
trained: diplomacy
lore: legal
feat: omen://feat/group-impression?source=paizo-pathfinder-player-core
description: |
  Piles of legal manuals, stern teachers, and courtroom experience...
```

```yaml
rules:
  - name: combat-flexibility
    at: 9
    grant:
      feat:
        choose:
          name: fighter_feats
          count: 2
          from:
            type: feat
            matching:
              all:
                - trait: fighter
                - level:
                    at_most: 8
    requires:
      - any:
          - attribute: { strength: 14 }
          - attribute: { dexterity: 14 }
```

## Delivery Order

1. OmenCore resolution and boolean requirement primitives.
2. OmenTome author model, workspace/index, rule DSL, CLI, schema generation.
3. OmenBuilder bridges, import/export transactions, and raw-editor validation.
4. OmenArchive manifest/schema migration, complete data rewrite, and CI conversion.

---

### Task 1: Add publication-aware OmenPath resolution in OmenCore

**Repository:** `OmenCore`

**Files:**
- Modify: `Sources/OmenCore/Utility/ResourceTag.swift`
- Modify: `Sources/OmenCore/RecordResolver/ResourceFilter/ResourceFilterComponent.swift`
- Modify: `Sources/OmenCore/RecordResolver/OmenPath+RecordDescriptor.swift`
- Modify: `Sources/OmenCore/RecordResolver/CharacterResourceResolver.swift`
- Modify: `Sources/OmenURI/OmenURI.swift`
- Test: `Tests/OmenURITests/OmenPathRecordDescriptorTests.swift`
- Test: `Tests/OmenCoreTests/RecordDescriptorTests.swift`

**Produces:** publication tags containing a source ID and published date; source-aware descriptors; `CharacterResourceResolver.resolve(omenPath:) -> [TypeWrappedCharacterRecord]` ordered by newest publication first.

- [ ] Add a publication identity/date value to the resource tag and make it Codable.
- [ ] Add a source component to `ResourceFilterComponent` and teach its evaluator to match publication ID.
- [ ] Make `OmenPath.toRecordDescriptor()` preserve `?source=` instead of dropping it.
- [ ] Define resolver ordering as descending `published`, then ascending publication ID; do not collapse matching versions in `resolve(omenPath:)`.
- [ ] Add tests for unqualified all-version resolution, source-qualified resolution, newest-first ordering, and deterministic ties.
- [ ] Run `swift test --package-path OmenCore` and commit the focused change.

### Task 2: Replace flat effect prerequisites with recursive requirements

**Repository:** `OmenCore`

**Files:**
- Create: `Sources/OmenCore/RecordResolver/ResourcePrerequisite/ResourceRequirement.swift`
- Modify: `Sources/OmenCore/CharacterBuilder/RulesEngine/CharacterEffect.swift`
- Modify: `Sources/OmenCore/CharacterBuilder/RulesEngine/CharacterEffect+Application.swift`
- Modify: `Sources/OmenCore/Utility/ResourceTag.swift`
- Test: `Tests/OmenCoreTests/CharacterBuilderTests.swift`
- Test: `Tests/OmenCoreTests/CodableTests.swift`

**Consumes:** Task 1’s source-aware resource metadata.

**Produces:** `ResourceRequirement` with `.all`, `.any`, `.not`, and `.leaf(ResourcePrerequisiteComponent)`; rule application evaluates its tree against a character slice.

- [ ] Write tests that demonstrate nested `all`, `any`, and `not`, including lookup-value leaves and diagnostics from a failing leaf.
- [ ] Implement recursive evaluation with short-circuit semantics and preserve current empty-prerequisite behavior as `true`.
- [ ] Change `CharacterEffect` and resource tags to carry a requirement tree rather than an implicit flat conjunction.
- [ ] Update Codable fixtures and run the OmenCore suite.
- [ ] Commit independently from Task 1.

### Task 3: Make selection policies support multi-choice and default restrictions

**Repository:** `OmenCore`

**Files:**
- Modify: `Sources/OmenCore/Selections/EncodedSelection.swift`
- Modify: `Sources/OmenCore/Selections/EncodedSelectionOptions.swift`
- Modify: `Sources/OmenCore/Selections/SelectionReconciler.swift`
- Modify: `Sources/OmenCore/CharacterBuilder/RulesEngine/CharacterEffect+Application.swift`
- Modify: `Sources/OmenCore/Models/Records/FeatRepeatPolicy.swift`
- Test: `Tests/OmenCoreTests/LookupSelectionPersistenceTests.swift`
- Test: `Tests/OmenCoreTests/RepeatableFeatIntegrationTests.swift`

**Consumes:** Task 2 requirement evaluator.

**Produces:** a selection specification that can request `count > 1`, evaluates candidate requirements by default, excludes already-owned resources, and rejects duplicates unless explicitly allowed.

- [ ] Add failing tests for two distinct selections, duplicate rejection, owned-feat rejection, unmet-candidate-prerequisite rejection, and each opt-in override.
- [ ] Extend selection storage/reconciliation to represent multiple selected typed values without conflating slots.
- [ ] Apply the default and override policies before materializing effects.
- [ ] Run the focused selection/rules suite and commit.

### Task 4: Deepen OmenTome into the archive-format module

**Repository:** `OmenBuilder`

**Files:**
- Modify: `OmenTome/Package.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ArchiveWorkspace.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ArchiveResource.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/PublicationManifest.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ArchiveCodec.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ArchiveDiagnostic.swift`
- Modify: `OmenTome/Sources/OmenTome/TomeCoder.swift`
- Test: `OmenTome/Tests/OmenTomeTests/ArchiveWorkspaceTests.swift`

**Consumes:** OmenURI parsing. This target must not import OmenCore.

**Produces:** a context-aware archive API that derives identities from paths, inherits manifests, indexes publication variants by OmenPath, and returns file/field diagnostics.

- [ ] Add OmenURI as an OmenTome package dependency and rename public `TomeCoder` entry points to archive-specific codec operations; delete compatibility entry points in the final commit.
- [ ] Define manifest decoding and require `id`, `publisher`, `title`, and `published`.
- [ ] Build a workspace index that resolves logical OmenPaths to all versions in newest-first order and supports exact source qualification.
- [ ] Add strict decoder behavior for unknown keys and diagnostics carrying file path, field path, and YAML location when available.
- [ ] Test manifest inheritance, title-case names, path/type mismatch, unknown key rejection, source ordering, and missing reference diagnostics.
- [ ] Run `swift test --package-path OmenTome` and commit.

### Task 5: Implement the author resource and rule DSL in OmenTome

**Repository:** `OmenBuilder`

**Files:**
- Modify: `OmenTome/Sources/OmenTome/CharacterAction.swift`
- Modify: `OmenTome/Sources/OmenTome/CharacterAncestry.swift`
- Modify: `OmenTome/Sources/OmenTome/CharacterBackground.swift`
- Modify: `OmenTome/Sources/OmenTome/CharacterClass.swift`
- Modify: `OmenTome/Sources/OmenTome/CharacterFeat.swift`
- Modify: `OmenTome/Sources/OmenTome/CharacterFeature.swift`
- Modify: `OmenTome/Sources/OmenTome/CharacterHeritage.swift`
- Replace: `OmenTome/Sources/OmenTome/CharacterRule.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/RequirementExpression.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ChoiceExpression.swift`
- Test: `OmenTome/Tests/OmenTomeTests/RulesCodingTests.swift`
- Test: `OmenTome/Tests/OmenTomeTests/ArchiveFormatTests.swift`

**Consumes:** Task 4 workspace/index.

**Produces:** the approved `snake_case` documents, domain-directed rule operations, value source grammar, choice filters, and recursive requirements.

- [ ] Replace camel-case archive coding keys with closed snake-case author DTOs and omit defaults, empty arrays, and empty strings during encoding.
- [ ] Implement `rules[].name`, `at`, `grant`, proficiency, modifier, spellcasting, lookup, and weapon-specialization operation families. No generic `kind`/`inputs` escape hatch is allowed.
- [ ] Implement values as literal, `choose`, or `lookup`; model `choose.count` and the three explicit `allow` switches.
- [ ] Implement shared `all`/`any`/`not` expressions, with rule requirement leaves and candidate matching leaves separated by type.
- [ ] Validate fixed OmenPaths as exact logical resources; choice filters are the only broad candidate selector.
- [ ] Replace the legacy rules tests with examples for fixed grants, dynamic selection, lookup consumption, version choices, exceptions, and nested boolean expressions.
- [ ] Run OmenTome tests and commit.

### Task 6: Add OmenTome formatting, schema output, and CLI validation

**Repository:** `OmenBuilder`

**Files:**
- Modify: `OmenTome/Package.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ArchiveFormatter.swift`
- Create: `OmenTome/Sources/OmenTome/Archive/ArchiveSchema.swift`
- Create: `OmenTome/Sources/OmenArchiveCLI/main.swift`
- Create: `OmenTome/Tests/OmenTomeTests/ArchiveFormatterTests.swift`
- Create: `OmenTome/Tests/OmenTomeTests/ArchiveSchemaTests.swift`

**Consumes:** Tasks 4 and 5.

**Produces:** `omenarchive validate`, `omenarchive format`, and `omenarchive schema` commands; portable generated JSON schemas.

- [ ] Add executable commands with nonzero exit status when diagnostics include errors.
- [ ] Make `format --check` report unformatted files without rewriting them and make ordinary validation non-mutating.
- [ ] Emit JSON schemas from the OmenTome author contract; remove reliance on the old shallow OmenSchemaGenerator output.
- [ ] Add golden tests for canonical formatting and schema snapshots.
- [ ] Run CLI tests and commit.

### Task 7: Rework OmenBuilder import, export, and editor integration

**Repository:** `OmenBuilder`

**Files:**
- Modify: `OmenScribe/DataStores/OmenArchive/OmenArchiveLoaders.swift`
- Modify: `OmenScribe/DataStores/OmenArchive/PublicationPackage.swift`
- Modify: `OmenScribe/DataStores/OmenArchive/OmenDBImporter.swift`
- Modify: `OmenScribe/DataStores/SwiftData/OmenTomeExtensions/CharacterRule+OmenCore.swift`
- Modify: `OmenScribe/DataStores/SwiftData/OmenTomeExtensions/OmenTome+ConversionExtensions.swift`
- Modify: `OmenScribe/DataStores/FPF2/OmenArchiveAdapter/FPF2OmenArchive+StoreFile.swift`
- Modify: `OmenScribe/Services/OmenArchive/OmenArchiveWriter.swift`
- Modify: `OmenScribe/Services/OmenArchive/Browser/OABFileBrowser.swift`
- Modify: `OmenScribe/Features/Workspace/Staging/AIEffectsApplier.swift`
- Test: `Tests macOS/OmenArchiveLoadingTests.swift`
- Test: `Tests macOS/OmenTomeBridgeTests.swift`
- Test: `Tests macOS/OmenScribeConfigurationTests.swift`

**Consumes:** Tasks 1–6.

**Produces:** OmenBuilder import/export paths using only OmenTome archive APIs; OmenCore bridges lower/raise author rules and deterministic identities; transactional import and staged export.

- [ ] Replace direct `TomeCoder.decode` calls with workspace-scoped decode/validate operations.
- [ ] Lower rule names to deterministic UUIDs using owner qualified OmenPath plus rule name; lower source-qualified fixed references and choice/filter/requirement expressions into OmenCore primitives.
- [ ] Reverse-resolve stored UUIDs to source-qualified OmenPaths on export and synthesize stable author rule/choice names when importing Foundry data lacks them.
- [ ] Validate all incoming records before opening the persistence transaction; roll back the publication on any error.
- [ ] Export to a staging directory, validate it using the CLI/library, and only then replace the destination.
- [ ] Make the raw editor validate with OmenTome without formatting or replacing the author’s original text.
- [ ] Add full archive import, export/re-import semantic round-trip, rollback, reverse-resolution, and raw-text-preservation tests.
- [ ] Run the focused macOS suite and commit.

### Task 8: Migrate OmenArchive data and retire the legacy contract

**Repository:** `OmenArchive`

**Files:**
- Create: `src/paizo-pathfinder-player-core/publication.yml`
- Modify: every YAML resource below `src/`
- Replace: `schemas/**/*.json`
- Replace: `scripts/validate.sh`
- Delete: `scripts/validator.rb`
- Create: `scripts/migrate-legacy-archive.swift` (temporary; remove before merge)
- Modify: `README.md`

**Consumes:** Tasks 4–6 and the OmenBuilder CLI release/checkout procedure.

**Produces:** one fully migrated archive with only the new contract and CLI-backed validation.

- [ ] Write the temporary migration tool and semantic snapshot comparator against the legacy input and new OmenTome output.
- [ ] Add the publication manifest with confirmed publisher/title/publication date and migrate all 423 files.
- [ ] Replace resource links with qualified OmenPaths; remove duplicate source blocks, default rarity, empty lore values, empty traits, and internal placeholders.
- [ ] Generate and check in the portable schemas.
- [ ] Change `scripts/validate.sh` to invoke the pinned OmenTome CLI for structural and semantic validation.
- [ ] Delete the temporary migrator, Ruby validator, legacy schemas, and legacy-format fixtures before merge.
- [ ] Run `omenarchive format --check .`, `omenarchive validate .`, and semantic before/after comparison; commit.

### Task 9: Enforce archive-format CI and release compatibility

**Repositories:** `OmenArchive`, `OmenBuilder`, `OmenCore`

**Files:**
- Modify: `OmenArchive/.github/workflows/*` or existing archive CI configuration
- Modify: OmenBuilder release/CI configuration that produces the pinned `omenarchive` CLI
- Test: CI workflow fixtures or scripts

**Consumes:** Tasks 1–8.

**Produces:** a reproducible archive validation environment and checks that prevent schema/CLI drift or legacy format reintroduction.

- [ ] Pin the OmenTome CLI version used by OmenArchive CI and document the update procedure.
- [ ] Require `omenarchive format --check .` and `omenarchive validate .` in archive CI.
- [ ] Fail CI when generated schemas differ from committed schemas.
- [ ] Add a legacy-rejection fixture covering `effectTemplate`, `inputRecipes`, `startLevel`, camel-case resource keys, and per-resource publisher/book metadata.
- [ ] Run each repository’s focused suite and record any existing unrelated failures separately.
- [ ] Commit CI changes.

## Ticket Dependency Graph

```text
Task 1 ─┬─ Task 4 ─ Task 5 ─ Task 6 ─ Task 7 ─ Task 8 ─ Task 9
Task 2 ─┤                          ▲
Task 3 ─┘                          │
       └───────────────────────────┘
```

Tasks 1–3 may proceed in parallel. Task 4 can begin after Task 1; Task 5 follows Task 4. Task 6 follows Task 5. Task 7 requires Tasks 1–6. Task 8 requires Task 6 and should land with Task 7’s compatible release. Task 9 is last.

## Verification Command Set

```bash
swift test --package-path OmenCore
swift test --package-path OmenBuilder/OmenTome
./scripts/validate.sh
omenarchive format --check .
omenarchive validate .
git diff --check
```

Run commands from their corresponding repository. The complete archive import/export test belongs to the OmenBuilder macOS test target and should be run after Tasks 1–7 land together.
