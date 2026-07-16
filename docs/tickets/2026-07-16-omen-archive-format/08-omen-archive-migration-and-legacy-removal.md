# 08 — Migrate OmenArchive and remove the legacy contract

**Repository:** `OmenArchive`
**Priority:** Migration
**Depends on:** 06; coordinate merge with 07
**Blocks:** 09

## Goal

Flag-day migrate all 423 archive resources to the approved human format, then delete every legacy decoder/schema/validator path. There is no compatibility window.

## Scope

- Create a `publication.yml` for every publication directory. Current manifest requires `id`, `publisher`, `title`, and `published`.
- Rewrite every resource to snake-case keys, title-cased display names, path-derived identity, inherited publication metadata, omitted defaults, and qualified OmenPaths.
- Replace all schemas with CLI-generated schemas.
- Replace the Ruby semantic validator with the pinned OmenTome CLI.
- Remove legacy schemas, fixtures, parsing code, and temporary migration tooling before merge.

## Migration safeguards

- Build a temporary converter against the old DTOs only long enough to generate new data.
- Produce semantic snapshots before and after conversion to detect lost field values.
- Review the known data-quality anomalies during conversion, including empty `loreSkill` values and keys not covered by old permissive schemas.
- Do not retain legacy parsing as a fallback.

## Files

- Create `src/<publication>/publication.yml`
- Modify every resource below `src/`
- Replace `schemas/**/*.json`
- Replace `scripts/validate.sh`
- Delete `scripts/validator.rb`
- Temporarily create a migration/snapshot script, then delete it before merge
- Update `README.md` and repository usage documentation

## Acceptance criteria

- All 423 resources are in the new format.
- `omenarchive format --check .` and `omenarchive validate .` succeed from the archive root.
- Semantic snapshots demonstrate equivalent imported data before and after migration, except for intentional representation/default normalization.
- No `effectTemplate`, `inputRecipes`, `startLevel`, UUID rule ID, camel-case archive field, or repeated publisher/book block remains.
- The repository contains no legacy decoder/validator compatibility path.

## Verification

```bash
omenarchive format --check .
omenarchive validate .
./scripts/validate.sh
git diff --check
```

Run the temporary semantic comparator before deleting it; retain its report in the merge/PR description rather than retaining the script.
