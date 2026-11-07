# Identities and Resource References

This document specifies how resources are identified, how cross-record references are authored, and how prose links are structured in OmenArchive.

## Resource Identity (OmenPath)

Every game element in the archive is addressed by a canonical, publication-qualified Uniform Resource Identifier called an **OmenPath**:

```text
omen://{family}/{path}?source={publication-id}
```

Examples:
- `omen://feat/additional-lore?source=paizo-pathfinder-player-core`
- `omen://ancestry/elf/heritages/seer-elf?source=paizo-pathfinder-player-core`
- `omen://class/fighter/features/reactive-strike?source=paizo-pathfinder-player-core`

Resource identity is derived entirely from the relative filesystem path of the record within its publication directory. Filesystem slugs must remain stable across updates.

### Name collisions

The encoding is lossy, by design: it lowercases, turns a run of spaces into one hyphen, and deletes other punctuation. Names that differ only in punctuation or case therefore share one OmenPath, and only one of them can be a record in a collection:

| Names | One OmenPath |
|---|---|
| `O'Brien`, `OBrien` | `obrien` |
| `Fire/Ice`, `FireIce`, `Fire_Ice` | `fireice` |
| `Weapon +1`, `Weapon 1` | `weapon-1` |
| `1/2`, `12` | `12` |

The second file fails the archive check with a duplicate identity. Write the distinction in words instead of punctuation where two names would otherwise collide (`weapon-plus-1`).

Publisher and book join with a hyphen after encoding too, so publisher `a b` with book `c`, and publisher `a` with book `b c`, both give the qualifier `a-b-c`. Two publications cannot both be checked out: their directory names collide, and the check reports the duplicate publication id before it reads a record. Keep publisher and book distinct when either name contains a space or punctuation.

## Authored Shorthand (`@` References)

When referencing another record within structured YAML fields (such as `prerequisites`, `featId`, `featureId`, or choice options), use the `@` shorthand:

<!-- docs-check: not a whole example — three reference fields shown on their own -->
```yaml
# Record in the current publication:
featId: '@feat.lie-to-me'

# Record in another publication:
featId: '@feat.lie-to-me?source=paizo-pathfinder-player-core'

# Member within a record:
featureId: '@feat.assurance#feature'

# Collection path prefix (for filtering options):
pathPrefix: '@class.witch.patrons'
```

### Unqualified Paths From Format 6

From format 6, one rule covers every reference and link in a file:

- **A path to a record without `?source=` means the file's own publication.** Nothing searches the other publications for it, and which other publications are installed never changes what a file means. A reference or link to a record that only another publication holds is an error. To point at another publication's record, write its `?source=`; a `?source=` therefore always means "from another publication".
- **A path to a collection keeps meaning every publication.** `pathPrefix: '@class.witch.patrons'` and `records:` name a set, and a later publication adds options to that set.
- **Prose links leave out the file's own `?source=`.** `[Trip](omen://action/trip)` is a link to the file's own publication; the decoded wire form (the JSONL and SQLite streams) keeps the qualified link, so a reader of the wire never needs this rule.
- **Structured `omen://` values, review notes and `externalRecords` keep their `?source=`.** Only links in descriptions compact.

Before format 6, the validator only warns about an unqualified `@` reference or link whose record only another publication holds (the rules below).

### Resolution Rules

1. **Unqualified References**: An `@` reference without `?source=` resolves to a record in the **same publication** as the referencing file. If the referenced record only exists in a different publication, the validator flags an `ambiguous` warning requiring an explicit `?source=`. From format 6 the warning is an error, and its message names the `?source=` to write.
2. **Missing Targets**: A reference that does not resolve in any publication of the archive produces a `dangling` error, unless explicitly registered in the publication's `externalRecords` list in `publication.yml`.
3. **YAML Quoting**: In YAML, `@` is a reserved indicator character. All shorthand references starting with `@` **must be quoted** in single or double quotes (`'@feat.example'`).
4. **No Raw UUIDs**: Never author raw UUIDs for record identities in YAML files.

## Markdown Links in Descriptions

Prose descriptions may link to other rules, actions, conditions, or features using standard CommonMark inline links with `omen://` destinations:

```yaml
description: |
  You attempt to [Trip](omen://action/trip) an opponent. On a success,
  the target falls [prone](omen://condition/prone). See also
  [Wizard Spellcasting](omen://class/wizard/features/arcane-spellcasting#spellbook).
```

### Description Linking Rules

- **Own Publication**: From format 6, write a link to a record of the file's own publication without `?source=` (`omen://action/trip`), and a link to another publication's record with it (`omen://action/trip?source=paizo-pathfinder-player-core`). Before format 6, an unqualified link resolves to the file's own publication's record first, and the validator warns when only one other publication has it (and reports an error when several do).
- **Destination Scheme**: Prose links must use the `omen://` URI scheme. The `@` shorthand is reserved exclusively for structured YAML reference fields.
- **Link Text**: Use natural, human-readable book casing for the link label (`[Trip]`, `[frightened 2]`). The label does not need to match the filename slug.
- **Checked Fields**: The archive validator scans inline links across `description`, `specialText`, `trigger`, `requirements`, `frequency`, `criticalSuccess`, `success`, `failure`, and `criticalFailure`.
- **Attribution Links**: External links using `https://` are permitted for author attribution or legal notices.
- **App-Internal Schemes**: App-specific schemes like `omen-character://` are strictly forbidden in archive content.
