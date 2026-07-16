# 06 — Add OmenTome formatting, schemas, and the omenarchive CLI

**Repository:** `OmenBuilder`
**Priority:** Core format
**Depends on:** 05
**Blocks:** 07, 08, 09

## Goal

Provide one portable command-line entry point for archive validation, canonical formatting, and schema output. OmenArchive CI consumes this CLI; OmenSchemaGenerator must no longer define the archive contract.

## Commands

```text
omenarchive validate <archive>
omenarchive format <archive> [--check]
omenarchive schema <output>
```

## Scope

- Add an executable target to OmenTome.
- Implement validation with nonzero exit status if error diagnostics are emitted.
- Implement canonical formatting and `--check` without mutating in check mode.
- Generate portable JSON schemas from the author contract.
- Add golden tests for format and schemas.

## Constraints

- Regular raw-editor saves must not invoke formatting.
- Formatting is explicit or performed by generated export only.
- Schemas are artifacts for editors/lightweight validation, not a second semantic authority.

## Likely files

- `OmenTome/Package.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ArchiveFormatter.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ArchiveSchema.swift`
- Create `OmenTome/Sources/OmenArchiveCLI/main.swift`
- Create formatter/schema tests

## Acceptance criteria

- `validate` validates manifests, resources, paths, references, rules, choices, and schemas through OmenTome.
- `format --check` reports every noncanonical file and exits unsuccessfully without rewriting it.
- `schema` emits deterministic output suitable for committing in OmenArchive.
- A snapshot change in the author model fails schema tests until schema output is intentionally updated.
- The old shallow schema-generator path is removed from the archive contract.

## Verification

```bash
swift test --package-path OmenTome
swift run --package-path OmenTome omenarchive --help
```
