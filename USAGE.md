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
    action/
    ancestry/
    background/
    class/
    feat/
    heritage/
    other-items/
```

`{publication}` is a slug for a book/source package, for example:

```text
src/paizo-pathfinder-player-core/
```

## General resource rules

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

`other-items/` is for curated data not yet represented by a top-level resource schema, such as domains.

Rules:

- Prefer adding a schema when the item becomes part of OmenDatabase/runtime.
- Do not let `other-items/` become a dumping ground for resources that already have a schema.

## Schema conventions

Schemas live under `schemas/` and use JSON Schema draft 2020-12.

Rules:

- Keep schema `$id` values stable and pointing at the raw GitHub URL.
- Shared concepts belong under `schemas/utility-types/`.
- If the YAML convention changes, update schema, OmenTome Codable model, and OmenScribe import tests together.
- Schema defaults must be mirrored by OmenTome decoders when OmenScribe needs to decode files directly.

## Validation checklist before import

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
