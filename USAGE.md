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
    class/                   # classes and their declared option collections
    feat/
    versatile-heritage/       # ancestry-owned heritages live under ancestry/<owner>/heritages/
    item/                  # Canonical equipment records (all subtypes)
    archetype/               # archetype bundles and owned feats
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
  - moduleID: me.atkn.omen.pf2e.playercore
    revision: 1
  - moduleID: me.atkn.omen.pf2e.playercore-spellcasting
    revision: 1
```

The manifest owns the publication qualifier. Its `id` must equal the canonical encoding of
`publisher` and `title`, joined with a hyphen. The title may contain punctuation because the
canonical OmenPath encoding removes punctuation consistently.

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

The archive owns reviewed mechanics. Preserve existing `rules`, `mechanicsScope` and
`unsupportedReason` when a Foundry record is regenerated. A feat's `typedPrerequisites` and
`prerequisiteDiagnostics` are generated from its prerequisite text (0143): a refresh replaces them,
so fix a prerequisite in the converter, not in the file. New records may take the converter's initial values for these fields; later reviewed
edits take precedence. If source identity changes or a field cannot be assigned to one owner,
show the conflict for review before writing. A hand-authored file with no staged counterpart is
an explicit removal candidate and must be reviewed before it can be deleted.

When a refresh finds a reviewed rule whose non-identity content no longer matches the generated
rule, it preserves the archive rule and creates a review item. It never silently drops a reviewed
mechanic. A generated rule may be added automatically only when every reviewed rule still matches.
The matcher ignores what identifies a rule rather than what it does: `id`, `key`, a choice's
`legacySelections`, and the identity inputs the converter derives from the rule (`selectionId`,
`grantId`, `entryId`, a roll modifier's `uuid`). A matched rule without a key stays exactly as
reviewed, since its released IDs can't be rederived; a matched keyed rule takes the generated ID
(derived from the current path) and keeps the archive's legacy selections. A reviewed key the
converter no longer produces is a divergence. A record the converter has no rules for keeps its
hand-authored rules without a review item.

`omendb-build player-core stage` lists the diverged records and writes the converter's own output
for each under `review/generated/` in the staging folder, outside what the gate hashes and Apply
copies. After comparing, restage with `--adopt-generated <file,…>` (or `@list`, one archive-relative
path per line) to take the generated mechanics for those records. Adoption still keeps the identity
of every rule that says what a reviewed rule says, gives a changed rule the ID and identity inputs
of the unkeyed reviewed rule with the same effect, and keeps each choice's legacy selections.

The schemas declare this ownership. An archive-owned property carries
`"x-omen-ownership": "archive"`, and a property without the annotation is generated. OmenScribe reads
the annotation (through `ArchiveFormat.archiveOwnedFields(for:)`) to decide which fields a refresh
keeps, so a new reviewed field must be annotated in its schema. The validator accepts the annotation
only on a property schema, with the value `archive` or `generated`.

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

Filename stems are stable kebab-case storage slugs. New records normally use the encoded display
name, but later display-name edits do not rename files or change identity. Domain slugs omit
the terminal `-domain`. Class and ancestry feature filenames have no level prefix.

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
- `publisher` and `book` preserve attribution on each resource and must match the publication
  manifest's `publisher` and `title` after canonical OmenPath text normalization.
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

Use `rules` on feats, features, ancestries, heritages and backgrounds when the entry needs to
grant or modify game state. Ancestries, heritages and backgrounds apply their inline rules at 1st
level; keep them to a few effects and put larger mechanics in feature records. Classes use feature
records only, never inline rules.
Leave the key out when there are no rules; do not add empty arrays to unchanged files.

```yaml
rules:
  - id: 11111111-1111-1111-1111-111111111111
    effectReference:
      kindID: me.atkn.omen.pf2e.playercore/effect/add-language
      revision: 1
    inputRecipes:
      - inputName: languageName
        expectedValue:
          valueTypeID: me.atkn.omen.pf2e.playercore/value/string
          source:
            kind: literal
            value:
              typeID: me.atkn.omen.pf2e.playercore/value/string
              revision: 1
              payload: Draconic
    startLevel: 1
    prerequisites:
      - hasClassTrait: true
```

Rules use the namespaced mechanics registry wire shape:

- `id` is a stable UUID for the rule instance.
- `key` is an optional readable kebab-case member name. A keyed rule's ID is
  `uuid5("<record-path>#rule/<key>")`; keys are unique within a resource and rule IDs are unique
  across the archive. Existing rules may omit `key` and retain their IDs.
- `effectReference.kindID` and `revision` identify the executable effect definition.
- `inputRecipes` carries typed effect inputs in order; each value includes its namespaced type ID and revision.
- `startLevel` is the level at which the rule becomes active.
- `prerequisites` stays as a list of typed prerequisite blocks instead of free-form text.

Foundry conversion assigns new keys as `<foundry-rule-key>-<n>`, where `n` is that source key's
occurrence in the record, counted over the Foundry rules rather than the converted ones, so an
inserted or reordered Foundry rule of another kind moves no other key. Rules the converter builds
for a purpose rather than from one Foundry rule get a key naming it (`choice-bard-muse`, named after
the choice), and spellcasting and focus rules keep their semantic IDs without a key. New authoring proposals use their explicit key when present; otherwise
they receive a random UUID. When an edited keyed rule is written, OmenScribe derives its ID from
the actual record path.

The character's traits come from three effects: `add-character-trait` (a plain trait),
`add-character-ancestry-trait` (an ancestry or lineage trait: it counts for `hasTrait` and opens
that ancestry's feats) and `add-character-adopted-ancestry-trait` (it only opens the feats). The
ancestry's own trait is added from the ancestry record; don't author it.

To gate a rule on the chosen ancestry's vision, use `hasAncestryVision: low-light-vision` (or
`normal`, `darkvision`). Don't gate on the character's senses: a rule gated on derived state can
satisfy itself.

Prefer literal values in `inputRecipes` when writing by hand. If a rule needs a new literal shape or prerequisite form, update the shared rule schema first so the archive, loader, and import paths stay in sync.

Spellcasting rules use `me.atkn.omen.pf2e.playercore-spellcasting`. Model an innate cantrip with
`rankPolicy: {kind: cantrip}` and `castFrequency: {kind: atWill}`. Model a fixed-rank
daily spell with `{kind: fixed, rank: N}` and `{kind: perDay, uses: N}`. Daily uses belong
to each spell grant; do not represent ancestry-granted innate spells as spell slots.

### Resource references

Use a plain `omen://` URI when a rule input refers to another curated resource:

```yaml
valueTypeID: me.atkn.omen.pf2e.playercore/value/feat-id
source:
  kind: lookupByID
  id: omen://feat/group-impression?source=paizo-pathfinder-player-core
```

Archive format 3 derives record paths from storage slugs, not display names. For example,
`class/fighter/features/armor-expertise.yml` maps to
`omen://class/fighter/features/armor-expertise`. The YAML `level` field carries the level;
the filename has no level prefix. Bundle roots use the enclosing directory slug.

An explicit `source` query limits resolution to one publication. Without `source`, all matching
publication versions are candidates; consumers that require one value use the newest publication
date. Equal latest dates require an explicit publication qualifier. Malformed or dangling references
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

`diagnostics` is an optional list of human-readable import notes for source-specific spell rules
that the source-independent spell model does not represent. Keep it distinct from `description`:
the description is rules text for readers, while diagnostics explain conversion limits.

The Player Core corpus manifest (`docs/player-core-corpus-manifest.json`) accounts for the
spells with every other Player Core record: all 488 source spells are archived. Each generated
payload retains Foundry's stable `sourceID` for source-aware rebuilds. Spells are refreshed with
the rest of the corpus, and `make player-core-check` in OmenBuilder verifies that a refresh
reproduces them. `docs/player-core-spell-import-manifest.json` is the older spell-only accounting
from the Python importer (0026). Nothing regenerates it; OmenScribe's Python-parity tests still
read it.

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
src/{publication}/ancestry/{ancestry}/heritages/{slug}.yml
src/{publication}/versatile-heritage/{slug}.yml
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
- Use `ancestry: versatile` for versatile heritages. Their inline rules add their lineage traits
  (`add-character-ancestry-trait`) and senses.
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
- Use feature filename slugs without level prefixes: `reactive-strike.yml`. Keep the level in YAML.
- Put class options in the owner-specific collection declared in `schemas/archive-format.json`. For example, bard options use `muses/`, rogue options use `rackets/`, wizard options use `schools/` or `theses/`, and witch options use `patrons/` or one of `basic-lessons/`, `greater-lessons/`, and `major-lessons/`. These collections use the `character-feature` schema and are part of the archive path contract.

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
- `typedPrerequisites`
- `prerequisiteDiagnostics`
- `relatedArchetype`
- `specialText`
- `action`

`typedPrerequisites` contains machine-readable prerequisite cases defined in
`schemas/utility-types/rules.schema.json`. Keep the authored wording in
`prerequisites` as well. When an importer cannot translate a source prerequisite,
it records an `unsupported` typed case and explains the translation in
`prerequisiteDiagnostics`; do not treat an unsupported condition as satisfied.

Rules:

- Keep prerequisites human-readable but consistent.
- OmenScribe currently parses common prerequisite strings into typed runtime prerequisites.
- Use `relatedArchetype` for archetype-associated feats.

### Archetypes

Archetypes are bundles. Store the archetype root at
`src/{publication}/archetype/{archetype}/{archetype}.yml` and its feats under
`src/{publication}/archetype/{archetype}/feats/{slug}.yml`. The root uses
`schemas/character-archetype.schema.json`; its owned feats remain `character-feat`
records and keep their feat record family when their paths move into the bundle.

The root's `entryFeat` is the publication-qualified OmenPath of its dedication feat:

```yaml
name: bard
source:
  publisher: paizo
  book: Pathfinder Player Core
description: |
  A short source description of the archetype.
entryFeat: omen://archetype/bard/feats/bard-dedication?source=paizo-pathfinder-player-core
```

Use only source-backed root fields. Do not infer progression or configuration rules
from feat names; add those fields only when the source provides them.

The Player Core historical path map, including ticket 0055 and batch 0162/0163/0146,
is recorded in `docs/migrations/player-core-0055-v1.0.0.json`. From the `OmenArchive` directory,
run `./scripts/player_core_0055_migration.py --check` to verify mapped destinations,
record UUIDs, and the eight source-backed roots. The script reads the corresponding
class descriptions from the workspace's `pf2e/` source checkout. Artifact version 2
requires the coordinated batch migration and gated refresh. The legacy `--apply`
command refuses that artifact because file moves alone cannot migrate saved identities.

## Mechanics coverage

Resource schemas share the optional `mechanicsScope` and `unsupportedReason`
fields from `schemas/utility-types/mechanics-support.schema.json`.

- `mechanicsScope` classifies mechanics coverage as `builder`, `encounter`, or `mixed`.
- `unsupportedReason` is a non-empty explanation when canonical mechanics could not be represented. It requires `mechanicsScope`, and the record must not also contain `rules`.
- `encounter` records cannot contain builder `rules`; `builder` records cannot set `unsupportedReason`.

Use these fields to make support limits explicit. Preserve useful source rules text
in `description`; do not add partial `rules` to avoid an unsupported classification.

### Other items

Domains and companions are top-level resource families with their own flat
directories. Archetypes are bundles whose owned feats live under `feats/`.
Domains use the singular host and filename leaf, such as `omen://domain/air` for
`domain/air.yml`, even when the display name is `air domain`. Historical domain
paths belong to the explicit migration map, not current runtime resolution.

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

Format version 2 also declares resource identity beside each layout: a family
sets its OmenPath host and whether its layout owner is part of identity, and
each bundle child or custom group names its owned collection. OmenArchiveKit
continues to read version 1 manifests with the historical identity mapping.
Grouped heritage identity omits its ancestry directory, so an inverse storage
path lookup needs that directory as explicit context.

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
