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

## Authored Shorthand (`@` References)

When referencing another record within structured YAML fields (such as `prerequisites`, `featId`, `featureId`, or choice options), use the `@` shorthand:

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

### Resolution Rules

1. **Unqualified References**: An `@` reference without `?source=` resolves to a record in the **same publication** as the referencing file. If the referenced record only exists in a different publication, the validator flags an `ambiguous` warning requiring an explicit `?source=`.
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

- **Destination Scheme**: Prose links must use the `omen://` URI scheme. The `@` shorthand is reserved exclusively for structured YAML reference fields.
- **Link Text**: Use natural, human-readable book casing for the link label (`[Trip]`, `[frightened 2]`). The label does not need to match the filename slug.
- **Checked Fields**: The archive validator scans inline links across `description`, `specialText`, `trigger`, `requirements`, `frequency`, `criticalSuccess`, `success`, `failure`, and `criticalFailure`.
- **Attribution Links**: External links using `https://` are permitted for author attribution or legal notices.
- **App-Internal Schemes**: App-specific schemes like `omen-character://` are strictly forbidden in archive content.
