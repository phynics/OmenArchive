# Using OmenArchive

OmenArchive is the human-edited source repository for Omen character resources.

It has two jobs:

1. Define the YAML/JSON-schema contract for resources.
2. Store curated resource files that can be imported into OmenDatabase by OmenScribe.

OmenArchive is the **source of truth** for curated game data. OmenDatabase is generated/published runtime state.

```text
Foundry JSON → OmenScribe staging → OmenArchive YAML → OmenScribe import → OmenDatabase
```

## Repository layout

```text
schemas/
  character-*.schema.json       # Resource schemas
  utility-types/*.schema.json   # Shared schema fragments

src/
  {publication}/
    publication.yml           # publication identity and release ordering
    action/
    spell/
    ancestry/
    background/
    class/
    feat/
    heritage/
    item/                  # Canonical equipment records (all subtypes)
    archetype/
    companion/
    domain/
```

`{publication}` is a slug for a book/source package, for example:

```text
src/paizo-pathfinder-player-core/
```

Each publication has a `publication.yml` manifest. Its `id` must match the folder name;
`published` is an ISO-8601 calendar date used to order unscoped OmenPath matches:

```yaml
id: paizo-pathfinder-player-core
publisher: Paizo
title: Pathfinder Player Core
published: "2023-11-15"
mechanicsModules:
  - moduleID: org.openomen.pf2e.core
    revision: 1
  - moduleID: org.openomen.pf2e.spellcasting
    revision: 1
```

## General resource rules

### Equipment taxonomy

Equipment uses one canonical `item/` resource family and one `omen://item/<name>` identity.
Each record declares `type` as `equipment`, `weapon`, `armor`, `shield`, `consumable`,
`container`, `treasure`, or `kit`; subtype-only fields live under the matching `details`
key. Shared physical values (`bulk`, `price`, `quantity`, hardness, hit points, usage, and
size) stay under `physical`, which keeps filtering and imports consistent across subtypes.

Inventory ownership, invested/equipped state, and bulk accounting are character-state data
and are intentionally outside the authored item record.

When an item originates in Foundry, `sourceID` retains its stable source-record ID alongside
the human-readable `source` block. This keeps repeated source-aware imports deterministic;
hand-authored items may omit it.

### Field ownership during a Foundry refresh

Match an existing record by its publication-qualified OmenPath or stable `sourceID`. A display
name is not a unique key. Foundry owns the descriptive and source fields it supplies, including
`name`, `description`, `traits`, `level`, `source`, `sourceID`, and source-specific item or spell
data. A refresh updates those fields from the new conversion.

The archive owns reviewed mechanics. Preserve existing `rules`, `typedPrerequisites`,
`mechanicsScope`, `unsupportedReason`, and `prerequisiteDiagnostics` when a Foundry record is
regenerated. New records may take the converter's initial values for these fields; later reviewed
edits take precedence. If source identity changes or a field cannot be assigned to one owner,
show the conflict for review before writing. A hand-authored file with no staged counterpart is
an explicit removal candidate and must be reviewed before it can be deleted.

### Encoding

All YAML files must be **UTF-8** text.

Do not save files as UTF-16. Some macOS editors can do this accidentally. UTF-16 YAML breaks normal tooling and OmenScribe import.

Quick check:

```sh
find src -type f -name '*.yml' -exec file {} \; | grep -v 'UTF-8\|ASCII'
```

This should print nothing.

### Naming

Use lowercase display names in YAML:

```yaml
name: reactive strike
```

Use kebab-case filenames based on the resource name:

```text
reactive-strike.yml
seer-elf.yml
administer-first-aid.yml
```

Prefer stable slugs over book typography. Apostrophes are currently present in a few files, but new files should avoid punctuation in filenames when a clean slug is possible.

### Source field

Every resource has a `source` block:

```yaml
source:
  publisher: paizo
  book: Pathfinder Player Core
  page: 123        # optional when known
  url: https://... # optional, mainly for third-party references
```

Rules:

- `book` is required by the schema.
- `publisher` defaults to `paizo`, but include it explicitly for readability.
- Use `page` when known.
- Use `url` for online/third-party reference material.

### Descriptions

Use YAML literal blocks for long text:

```yaml
description: |
  First paragraph.

  Second paragraph.
```

Keep rules text readable for humans. Avoid injecting Foundry-specific JSON/rule elements into descriptions unless they are actual user-facing text.

### Rules

Use `rules` on feats, features, and heritages when the entry needs to grant or modify game state.
Leave the key out when there are no rules; do not add empty arrays to unchanged files.

```yaml
rules:
  - id: 11111111-1111-1111-1111-111111111111
    effectReference:
      kindID: org.openomen.pf2e.core/effect/add-language
      revision: 1
    inputRecipes:
      - inputName: languageName
        expectedValue:
          valueTypeID: org.openomen.pf2e.core/value/string
          source:
            kind: literal
            value:
              typeID: org.openomen.pf2e.core/value/string
              revision: 1
              payload: Draconic
    startLevel: 1
    prerequisites:
      - hasClassTrait: true
```

Rules use the namespaced mechanics registry wire shape:

- `id` is a stable UUID for the rule instance.
- `effectReference.kindID` and `revision` identify the executable effect definition.
- `inputRecipes` carries typed effect inputs in order; each value includes its namespaced type ID and revision.
- `startLevel` is the level at which the rule becomes active.
- `prerequisites` stays as a list of typed prerequisite blocks instead of free-form text.

Prefer literal values in `inputRecipes` when writing by hand. If a rule needs a new literal shape or prerequisite form, update the shared rule schema first so the archive, loader, and import paths stay in sync.

Spellcasting rules use `org.openomen.pf2e.spellcasting`. Model an innate cantrip with
`rankPolicy: {kind: cantrip}` and `castFrequency: {kind: atWill}`. Model a fixed-rank
daily spell with `{kind: fixed, rank: N}` and `{kind: perDay, uses: N}`. Daily uses belong
to each spell grant; do not represent ancestry-granted innate spells as spell slots.

### Resource references

Use a plain `omen://` URI when a rule input refers to another curated resource:

```yaml
valueTypeID: org.openomen.pf2e.core/value/feat-id
source:
  kind: lookupByID
  id: omen://feat/group-impression?source=paizo-pathfinder-player-core
```

The URI path uses the resource's canonical encoded `name`, not its filename. For example,
`name: armor expertise` is referenced as `omen://class/fighter/features/armor-expertise`,
even when the storage filename contains a level prefix such as `7-armor-expertise.yml`.

An explicit `source` query limits resolution to one publication. Without `source`, all matching
publication versions are candidates; consumers that require one value use the newest publication
date, with the publication ID as a deterministic tie-breaker. Malformed or dangling references
must be fixed before Archive-to-OmenDB export. Registered UUID payloads remain valid for executable
runtime inputs; use a lookup source when a rule should resolve a curated resource by OmenPath.

### Traits and enums

Use lowercase enum/string values:

```yaml
traits:
- manipulate
- skill
```

Common enum examples:

```yaml
rarity: common
vision: low-light
count: two_actions
```

Prefer schema-defined values. If a value is not represented by a schema yet, update the schema/model deliberately rather than inventing one-off strings in many files.

## Category conventions

### Actions

Path:

```text
src/{publication}/action/{slug}.yml
```

Schema:

```text
schemas/character-action.schema.json
```

Example:

```yaml
name: administer first aid
source:
  publisher: paizo
  book: Pathfinder Player Core
description: |
  You perform first aid...
traits:
- manipulate
- skill
count: two_actions
requirements: You're wearing or holding a Healer's Toolkit.
success: |
  ...
criticalFailure: |
  ...
```

Action-specific fields come from `schemas/utility-types/action-primitive.schema.json`:

- `count`
- `requirements`
- `trigger`
- `frequency`
- `criticalSuccess`
- `success`
- `failure`
- `criticalFailure`

### Spells

Spells live in `src/{publication}/spell/{slug}.yml` and use
`schemas/character-spell.schema.json`. `rank` is 0 for cantrips and 1–10 for ranked spells;
`category` explicitly distinguishes `spell`, `cantrip`, `focus`, and `ritual`. Keep the four
traditions in `traditions`, ordinary Foundry traits in `traits`, and use `defense` and
`heightening` only for the supported structured fields. Foundry rule elements and UUID markup do
not belong in archive YAML; preserve unsupported effects as reviewed prose in `description` and
record a diagnostic during staging.

The checked-in Player Core import is accounted by
`docs/player-core-spell-import-manifest.json`: 488 source records produce 465 YAML files and 23
reviewed skips. Each generated payload retains Foundry's stable `sourceID` for source-aware
rebuilds. Re-run `python3 tools/player_core_spell_import.py --check` from the workspace root to
verify source IDs, hashes, deterministic slugs, and the generated-file set.

### Ancestries

Path:

```text
src/{publication}/ancestry/{ancestry}/{ancestry}.yml
src/{publication}/ancestry/{ancestry}/features/{slug}.yml
```

Schema:

```text
schemas/character-ancestry.schema.json
schemas/character-feature.schema.json
```

Example:

```yaml
name: elf
source:
  publisher: paizo
  book: Pathfinder Player Core
description: |
  ...
rarity: common
hitPoints: 6
traits:
- elf
- humanoid
attributes:
  freeBoosts: 1
  strength: neutral
  dexterity: boost
  constitution: flaw
  intelligence: boost
  wisdom: neutral
  charisma: neutral
languages:
- elven
- common
languageAccess:
- draconic
additionalLanguages: 0
speed: 30
vision: low-light
size: medium
```

Rules:

- Keep base ancestry data in `{ancestry}.yml`.
- Put ancestry features in `features/` as `character-feature` YAML.
- Feature names should not duplicate the ancestry name unless the book does so.

### Heritages

Path:

```text
src/{publication}/heritage/{ancestry}/{slug}.yml
src/{publication}/heritage/versatile/{slug}.yml
```

Schema:

```text
schemas/character-heritage.schema.json
```

Example:

```yaml
name: seer elf
source:
  publisher: paizo
  book: Pathfinder Player Core
description: |
  ...
rarity: common
ancestry: elf
```

Rules:

- `ancestry` is the owning ancestry slug, e.g. `elf`.
- Use `ancestry: versatile` for versatile heritages.
- The directory must match the `ancestry` value.

### Backgrounds

Path:

```text
src/{publication}/background/{slug}.yml
```

Schema:

```text
schemas/character-background.schema.json
```

Backgrounds support either a single inline variant or a `variants:` array.

Single variant:

```yaml
name: bandit
source:
  publisher: paizo
  book: Pathfinder Player Core
description: |
  ...
attributes:
  freeBoosts: 1
  chooseFrom:
  - charisma
  - dexterity
skillOption:
- intimidation
loreSkill: plains
skillFeat: group coercion
```

Multiple variants:

```yaml
name: scholar
source:
  publisher: paizo
  book: Pathfinder Player Core
description: |
  ...
variants:
- attributes:
    freeBoosts: 1
    chooseFrom:
    - intelligence
    - wisdom
  skillOption: arcana
  loreSkill: academia
  skillFeat: assurance(arcana)
```

Rules:

- `rarity` defaults to `common`; include it explicitly when uncommon/rare/unique.
- Use `variants` when the choice changes granted skill or feat.
- Avoid empty strings when possible. Prefer a real lore slug once known.

### Classes

Path:

```text
src/{publication}/class/{class}/{class}.yml
src/{publication}/class/{class}/features/{level}-{slug}.yml
```

Schema:

```text
schemas/character-class.schema.json
schemas/character-feature.schema.json
```

Example class:

```yaml
name: fighter
source:
  publisher: paizo
  book: Pathfinder Player Core
rarity: common
description: |
  ...
keyAttribute:
- dexterity
- strength
hitPoints: 10
gainsFeatAtFirstLevel: true
armorProficiency:
  heavy: trained
  unarmored: trained
  light: trained
  medium: trained
weaponProficiency:
  advanced: trained
  unarmored: expert
  martial: expert
  simple: expert
savingThrowProficiency:
  fortitude: expert
  reflex: expert
  will: trained
  perception: expert
additionalSkillCount: 3
grantedSkills: []
electiveSkills:
  choose: 1
  from:
  - acrobatics
  - athletics
```

Example feature:

```yaml
name: reactive strike
source:
  publisher: paizo
  book: Pathfinder Player Core
level: 1
traits:
- fighter
action: {}
description: |
  Ever watchful...
```

Rules:

- Keep base class data in `{class}.yml`.
- Put fixed class features in `features/`.
- Prefix feature filenames with level when the feature is level-gated: `1-reactive-strike.yml`.
- Class-specific choice sets can live in class subdirectories, e.g. `rackets/`, `schools/`, `theses/`, `lessons/`, until a more explicit schema exists.

### Feats

Path:

```text
src/{publication}/feat/{slug}.yml
```

Schema:

```text
schemas/character-feat.schema.json
```

Expected shape:

```yaml
name: example feat
source:
  publisher: paizo
  book: Pathfinder Player Core
level: 1
rarity: common
traits:
- general
description: |
  ...
prerequisites:
- trained in Arcana
action:
  count: one_action
```

Supported optional fields:

- `alternateLevels`
- `prerequisites`
- `relatedArchetype`
- `specialText`
- `action`

Rules:

- Keep prerequisites human-readable but consistent.
- OmenScribe currently parses common prerequisite strings into typed runtime prerequisites.
- Use `relatedArchetype` for archetype-associated feats.

### Other items

Domains and companions are top-level resource families with their own flat
directories. Archetypes are bundles whose owned feats live under `feats/`.
The domain directory is singular for storage, but canonical OmenPath references
remain plural: `omen://domains/<name>`. Migration tools must preserve that
identity when they move a domain file.

## Schema conventions

Schemas live under `schemas/` and use JSON Schema draft 2020-12.

Rules:

- Keep schema `$id` values stable and pointing at the raw GitHub URL.
- Shared concepts belong under `schemas/utility-types/`.
- If the YAML convention changes, update schema, OmenTome Codable model, and OmenScribe import tests together.
- Schema defaults must be mirrored by OmenTome decoders when OmenScribe needs to decode files directly.

## Validation checklist before import

Primary command:

```sh
./scripts/validate.sh
```

The script runs the released-validation path through
[OmenArchiveKit](https://github.com/phynics/OmenArchiveKit), the reference
implementation of the archive format. It resolves the Kit from
`OMEN_ARCHIVE_KIT_ROOT` when set (use this for local Kit development),
otherwise from a checkout at `../OmenArchiveKit`. The schemas stay in this
repository; `schemas/archive-format.json`'s `version` field is the
compatibility seam between the two — a Kit release declares the format
versions it understands and fails with a distinct diagnostic outside that
range.

Optional local hook:

```sh
./scripts/install-pre-commit.sh
```

Run these checks before importing into OmenDatabase:

- All YAML files are UTF-8.
- YAML parses.
- Files decode into their OmenTome types.
- OmenScribe reports zero `ArchiveLoadFailure`s.
- Directory path matches the resource category and slug.
- `source.book` is present.
- `rarity` is explicit when not common.
- Cross-resource references make sense, e.g. heritage ancestry exists.

## Editing rules

- Keep files small and one resource per YAML file.
- Prefer explicit data over prose when a schema field exists.
- Do not store raw Foundry JSON in OmenArchive YAML.
- Do not use app/database IDs as resource identity.
- Use stable slugs and source metadata for identity.
- If a file cannot be represented cleanly, add a TODO/comment in the PR/commit, not an invalid schema workaround in the YAML.
