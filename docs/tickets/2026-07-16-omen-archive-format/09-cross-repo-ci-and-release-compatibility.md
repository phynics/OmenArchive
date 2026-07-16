# 09 — Enforce archive-format CI and pinned OmenTome compatibility

**Repositories:** `OmenArchive`, `OmenBuilder`, and compatibility checks in `OmenCore`
**Priority:** Release hardening
**Depends on:** 01–08

## Goal

Make archive validation reproducible outside the umbrella checkout. OmenArchive CI must use a known OmenTome CLI version and must prevent formatting drift, schema drift, and legacy-format reintroduction.

## Scope

- Define how OmenBuilder releases or publishes the `omenarchive` executable used by OmenArchive.
- Pin the consumed version/revision in OmenArchive CI.
- Document CLI update procedure and compatibility expectations.
- Require canonical formatting, semantic validation, and generated-schema drift checks in CI.
- Add negative fixtures that prove legacy documents fail.

## Compatibility contract

- OmenArchive only validates with an explicitly pinned OmenTome release/revision.
- Updating the archive contract requires updating OmenTome tests, schemas, CLI version, archive schemas, and this pin in one coordinated change.
- OmenCore runtime behavior is covered by its own test suite; OmenArchive CI validates the author contract through the CLI.

## Acceptance criteria

- A clean CI checkout can acquire and run the pinned CLI without relying on a sibling local repository.
- CI runs `omenarchive format --check .` and `omenarchive validate .`.
- CI fails when committed schemas differ from generated schemas.
- CI rejects fixtures using `effectTemplate`, `inputRecipes`, `startLevel`, camel-case resource keys, or per-file `publisher`/`book` blocks.
- The update procedure identifies which OmenBuilder/OmenArchive changes must land together.

## Verification

- Execute the archive CI workflow or equivalent local script from a clean checkout.
- Run the OmenTome schema and CLI suites at the pinned revision.
- Confirm a valid archive passes and each legacy negative fixture fails with a specific diagnostic.
