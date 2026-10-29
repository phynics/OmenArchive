# Troubleshooting Common Validation Errors

This guide documents the most common schema, reference, and mechanics validation errors in OmenArchive, explains why they occur, and shows how to resolve them.

---

## 1. Schema Validation Errors

Run the standalone schema check:
```bash
npm run check-schemas
# or
node scripts/check-schemas.mjs [path/to/file.yml]
```

### `schema error at $.<field>: is required`
- **Cause**: A mandatory property required by the schema is missing.
- **Example**: In a spell, omitting `rank` or `category`.
- **Fix**: Inspect the relevant schema under `schemas/` and add the missing property to your YAML file.

### `schema error at $.<field>: must match "pattern"`
- **Cause**: A string does not follow the expected format (e.g. kebab-case or URI pattern).
- **Example**: Using uppercase letters or spaces in an action or feat slug: `slug: "Reactive Strike"`.
- **Fix**: Use lowercase kebab-case: `slug: "reactive-strike"`.

### `YAML parse error: ...`
- **Cause**: Invalid YAML syntax, typically improper indentation, unquoted special characters, or tabs.
- **Example**: Starting a value with `@` without quotes: `featId: @feat.example`.
- **Fix**: Quote references in single or double quotes: `featId: '@feat.example'`. Ensure only 2-space indentation is used (no tabs).

---

## 2. Resource Reference and Link Errors

### `OmenPath reference does not resolve in the archive: @<reference>`
- **Cause**: An `@` shorthand or `omen://` link points to a slug that does not exist.
- **Fix**:
  1. Check for typos in the family name or record slug.
  2. If referencing a record in a different publication, include `?source=<pub-id>`:
     `'@feat.example?source=paizo-pathfinder-player-core'`.
  3. If referencing a record from a book not yet in the archive, declare it in `externalRecords` in `publication.yml`.

### `Unqualified reference resolves to another publication's record: @<reference>`
- **Cause**: An `@` reference omitted `?source=`, but the record is only found in a different publication.
- **Fix**: Add `?source=<pub-id>` to make the publication explicit.

### `Malformed OmenPath reference: <reference>`
- **Cause**: The reference syntax is invalid.
- **Fix**: In structured fields, use `'@family.slug'` or `'@family.slug#member'`. In Markdown prose descriptions, use `omen://family/slug`.

---

## 3. Mechanics and Rule Errors

Full mechanics validation runs in maintainer CI via `./scripts/validate.sh`.

### `mechanics [unknownEffect] Effect <name> is not registered`
- **Cause**: The rule names an effect that does not exist in the referenced mechanics module.
- **Fix**: Check `docs/mechanics.docc/` or `mechanics/*.json` for the exact effect name and module alias.

### `mechanics [missingInput] Input <name> is required`
- **Cause**: An effect requires an input parameter that was not provided in `inputs:`.
- **Fix**: Check the effect's inputs in `docs/mechanics.docc/` and provide the required input in `inputs:`.

### `mechanics [duplicateRuleKey] Two rules share a key`
- **Cause**: Two rule blocks in the same record have the same `key:`.
- **Fix**: Ensure every rule in a file has a distinct, descriptive `key` (e.g., `grant-feat-1`, `grant-feat-2`).

### `mechanics [choiceNameRepeatsRecord]`
- **Cause**: A choice name repeats the enclosing record's slug in its final path segment.
- **Fix**: Name the choice using plural categories (e.g., `$.feat.terrain-expertise.terrains` instead of `$.feat.terrain-expertise.terrain-expertise-terrain`).

