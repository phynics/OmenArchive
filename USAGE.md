# Using OmenArchive

OmenArchive is the human-edited source repository for Omen character resources.

It has two jobs:

1. Define the YAML/JSON-schema contract for resources.
2. Store the curated resource files that OmenDB is built from.

OmenArchive is the **source of truth** for curated game data. OmenDB, the store the apps read, is
always rebuilt from it and never edited.

```text
Foundry JSON → conversion and review → OmenArchive YAML → rebuild → OmenDB
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

When an item originates in Foundry, `foundryID` retains its stable source-record ID alongside
the human-readable `source` block. This keeps repeated source-aware imports deterministic;
hand-authored items may omit it.

### Field ownership during a Foundry refresh

Match an existing record by its publication-qualified OmenPath or stable `foundryID`. A display
name is not a unique key. Foundry owns the descriptive and source fields it supplies, including
`name`, `description`, `traits`, `level`, `attribution`, `foundryID`, and source-specific item or spell
data. A refresh updates those fields from the new conversion.

The archive owns reviewed mechanics. Preserve existing `rules`, `mechanicsScope` and
`unsupportedReason` when a Foundry record is regenerated. A feat's `prerequisites` (the text and the
typed form and diagnostic beside it) are generated from its prerequisite text: a refresh replaces
them, so fix a prerequisite in the converter, not in the file. New records may take the converter's
initial values for these fields; later reviewed edits take precedence. If source identity changes or a field cannot be assigned to one owner,
show the conflict for review before writing. A hand-authored file with no staged counterpart is
an explicit removal candidate and must be reviewed before it can be deleted.

A refresh never silently drops a reviewed mechanic: when a reviewed rule no longer matches what
the converter generates, the archive rule is kept and the record goes to review. Differences in
spelling alone (key order, quoting, `@` form) are not divergences.

The schemas declare this ownership. An archive-owned property carries
`"x-omen-ownership": "archive"`, and a property without the annotation is generated. A refresh
keeps the archive-owned fields, so a new reviewed field must be annotated in its schema. The validator accepts the annotation
only on a property schema, with the value `archive` or `generated`.

### Encoding

All YAML files must be **UTF-8** text.

Do not save files as UTF-16. Some macOS editors can do this accidentally. UTF-16 YAML breaks normal tooling and import.

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

### Source and attribution

A resource file has no `source` block: its directory (`src/<publication>/`) and the publication's
`publication.yml` already say where it comes from. The loader fills `publisher` (the publication's,
lowercased) and `book` (its `title`) in. An optional `attribution` holds what the publication
doesn't say:

```yaml
attribution:
  page: 123        # when known
  url: https://... # mainly for third-party references
```

- `attribution.publisher` and `attribution.book` are only for a record whose own publisher or book
  differs; if given, they must match the publication manifest's `publisher` and `title` after
  canonical OmenPath text normalization.
- The identifier Foundry gave a record is `foundryID`, not `source`.

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
  effect: core/add-language
  level: 3                 # left out when 1
  prerequisites:
  - hasClassTrait: true
  inputs:
    languageName: Draconic
```

A rule has these keys, in this order:

- `id` is a stable UUID for the rule instance. It is always written. A keyed rule's ID is
  `uuid5("<record-path>#rule/<key>")` and the validator rejects one that disagrees.
- `key` is an optional readable kebab-case member name. Keys are unique within a resource and rule
  IDs are unique across the archive.
- `effect` is `<module alias>/<effect>`, with `@<revision>` for a revision other than 1
  (`core/add-feat@2`). The aliases are declared once, in `publication.yml`'s `mechanicsModules`.
- `level` is the level at which the rule becomes active; 1 when left out.
- `prerequisites` is a list of typed prerequisite blocks.
- `inputs` maps each input name to its value.

An input value is **bare** when it is a literal: the effect's descriptor says its type, so there is
no type ID, revision or namespace (`proficiencyCap: 2`, `skill: {kind: deception}`). The explicit
forms are `{choice: $.cleric.divine-font}` (read a named choice), `{selection: …}`
and `{literal: …}` (with an optional `type: core/skill`, for a payload that looks
like one of the explicit forms). A string literal that starts with `$`, `@` or `(`, or with `[[`, is
written with a leading backslash (`\$5`): those prefixes are reserved for character values,
references, expressions and sheet values. Expressions (`(max 1 (divide $.level 2))`) and `$` values have no wire
form yet and are rejected.

A **record** input (a feat, action, feature or spell ID) takes a reference, never a UUID:
`featId: '@feat.lie-to-me'`. See "Resource references".

A **choice** is a rule with `choice:` in place of `effect:` and `inputs:`:

```yaml
- id: 7be6e4c7-d7c1-570e-8c0c-dc5dfe5c0c7e
  key: choice-cleric-divine-font
  choice:
    name: $.cleric.divine-font
    label: Divine Font
    type: spellcasting/spell-id
    cases:
    - {value: '@spell.heal'}
    - {value: '@spell.harm'}
```

One of `cases`, `records` (`{filter, type}`) or `freeText` (a type) gives the options. A case's
`key` is left out when it is the value's own text and its `label` when it is the key's words
capitalized; a case may instead hold `effects` (rule entries with no `level`) that apply when it is
picked. A choice's `level` is the rule's, unless it says otherwise.

Foundry conversion assigns new keys as `<foundry-rule-key>-<n>`, where `n` is that source key's
occurrence in the record, counted over the Foundry rules rather than the converted ones, so an
inserted or reordered Foundry rule of another kind moves no other key. Rules the converter builds
for a purpose rather than from one Foundry rule get a key naming it (`choice-bard-muse`, named after
the choice), and spellcasting and focus rules keep their semantic IDs without a key. New authoring
proposals use their explicit key when present; otherwise they receive a random UUID. When an edited
keyed rule is written, its ID is derived from the actual record path.

The character's traits come from `add-character-trait` (a plain trait) and
`add-character-ancestry-trait` (an ancestry or lineage trait: it counts for `hasTrait` and opens
that ancestry's feats). The ancestry's own trait is added from the ancestry record; don't author
it. The ancestries whose feats an ancestry feat slot offers are the list `$.ancestry.feat-ancestries`:
the character's real ancestry traits, and the ancestries `add-feat-ancestry` adds. The effect only
opens the feats; the character doesn't become that ancestry, so no prerequisite sees it.

To gate a rule on the chosen ancestry's vision, use `hasAncestryVision: low-light-vision` (or
`normal`, `darkvision`). Don't gate on the character's senses: a rule gated on derived state can
satisfy itself.

Prefer literal values in `inputs` when writing by hand. If a rule needs a new literal shape or
prerequisite form, update the shared rule schema first so the archive, loader, and import paths stay
in sync.

Spellcasting rules use the `spellcasting` module. Model an innate cantrip with
`rankPolicy: {kind: cantrip}` and `castFrequency: {kind: atWill}`. Model a fixed-rank
daily spell with `{kind: fixed, rank: N}` and `{kind: perDay, uses: N}`. Daily uses belong
to each spell grant; do not represent ancestry-granted innate spells as spell slots.

### Filters

A resource filter is a list or a leaf, with no wrapper:

```yaml
options:
  filter:
    all:
    - {type: spell}
    - {spell.category: cantrip}
    - {spell.tradition: arcane}
    - {rarity: common}
```

`all` and `any` take lists of filters. A leaf has one key: `type`, `rarity`, `level` (exact),
`maxLevel`, `name`, `trait`, `id` (a record reference), `excludesIds`, `pathPrefix` (a collection
such as `@class.witch.patrons`), `sharesAncestryTrait`, `sharesClassTrait`, `characterHasFeat`,
`hasChoiceAncestryTrait` (the ancestry trait a choice picked, `$.feat.adopted-ancestry.ancestry`),
`everything`, or a metadata key written with its dot (`spell.category: cantrip`). `not` takes one
`trait` leaf (`{not: {trait: uncommon}}`); no other negation exists yet. A filter that fits in 56
characters stays on one line; a longer one puts each item of its `all`/`any` list on its own line.

A character can count as a member of something it didn't pick: the `core/add-membership` effect
adds a feature to a named list (`$.druid.order-memberships`, `$.bard.muse-memberships`). The
class's own order or muse adds its pick, and Order Explorer and Multifarious Muse add theirs, so a
prerequisite asks `hasChoice: {name: $.druid.order-memberships, contains: '@class.druid.orders.leaf'}`
and the pick (`$.druid.order`) stays the character's own. Lists are derived at every level and
never saved.

### Spellcasting tables

A caster's class feature writes its slots and spell picks once, as the book's table, in a
`spellcasting:` block. It is authoring shorthand: reading the archive expands it into the feature's
first rules (`configure-source`, `increase-source-proficiency`, then `grant-slot` and
`add-known-spell` by level), and writing turns rules that are exactly such an expansion back into
the block. A block names no UUID: rule IDs are derived from the record's path and the rule's key
(`<path>#rule-slot-3-2`).

```yaml
spellcasting:
  source: {kind: prepared, tradition: arcane, attribute: int}
  slots:                       # cumulative, as the book prints them: cantrips, then ranks 1-10
    1: [5, 2]
    2: [5, 3]
    3: [5, 3, 2]               # a level with no row repeats the row before it
  spellbook:                   # picks into the spellbook or repertoire, by level or range
    1: {cantrips: 10, rank-1: 5}
    2-20: {any-rank: 2}        # or {new-slots: true}: one per new slot, {rank-10: n} for the 10th-rank slot
```

- Cleric and druid have `slots` only: they prepare from the whole list.
- A record that adds to another's source names the feature that defines it instead of a map:
  `source: '@class.wizard.features.wizard-spellcasting'`. A wizard school writes
  `spellbook: {from: curriculum}`, which reads the record's own `curriculum:` (an extra slot and
  the listed spells for each rank, uncommon spells included). A record that adds a pick from a
  tradition list also names `tradition:`; `ids: <folder>` names the folder the rule IDs derive from
  when it is not `features`.
- The witch's table is one block on Witch Spellcasting with `source: patron`: each patron
  configures the source's tradition, and the spellbook offers the spells of that tradition. A lesson
  or patron that gives one more pick from a short list writes `choose:` with the spells' `@spell`
  references.
- Expert, Master and Legendary Spellcaster stay separate features. Focus and innate spells stay
  as rules.
- A slot row can't have fewer slots than the row before it; the block's rules come first among the
  record's own `rules:`, and a `rules:` entry can't reuse an ID the block's expansion makes.

### Archive format 4

Format 4 is a spelling of the same data: reading a file gives the same rules and records as
format 3 did. What changed:

- Rules use `effect` and `inputs`, with bare literals (above); filters are flat; choice rules are
  compact.
- Records are named by `@` reference, not UUID; no rule holds a record UUID. Rule IDs and the other
  identities (`selectionId`, `grantId`, `sourceId`, `legacySelections`) stay UUIDs, since they are
  identities, not references.
- No `source` block, no empty `action`, `foundryID` for `sourceID`, and a feat's `prerequisites`,
  `typedPrerequisites` and `prerequisiteDiagnostics` are one list (see "Feats").
- Keys follow a fixed order per family (a feat: `name`, `level`, `rarity`, `type`, `traits`,
  `prerequisites`, `action`, `description`, …, `foundryID`, `attribution`, `rules` last) in every
  writer, and scalars are written the way the writers always wrote them.

`omen-archive migrate-format-4 <archive-root> [--write]` rewrites a format 3 archive, and writes
nothing unless every file reads back as the same document.

### Resource references

A record is written `@family.name`, steps joined by dots, with an optional `#member` and then
`?source=`:

```yaml
featId: '@feat.lie-to-me'                       # this publication's record
featId: '@feat.lie-to-me?source=other-book'     # another publication's
featureId: '@feat.assurance#feature'            # a member of a record
pathPrefix: '@class.witch.patrons'              # a collection
```

`@feat.additional-lore` is `omen://feat/additional-lore`. Without `?source=` a reference means the
file's own publication's record when the store is built; the validator warns when it only finds the
record in another publication. A reference to a record no publication of the archive holds (Natural
Ambition leaves out feats of books the archive lacks) is declared in `publication.yml`'s
`externalRecords`, as full `omen://…?source=…` paths; any other reference that doesn't resolve is an
error. Quote references in YAML, since `@` can't start a plain scalar.

Record paths come from storage slugs, not display names. For example,
`class/fighter/features/armor-expertise.yml` maps to
`omen://class/fighter/features/armor-expertise`. The YAML `level` field carries the level;
the filename has no level prefix. Bundle roots use the enclosing directory slug.

Plain `omen://` URIs remain in fields that hold a path as text (`entryFeat`, `grantedSpells`).
An explicit `source` query limits resolution to one publication. Without `source`, all matching
publication versions are candidates; consumers that require one value use the newest publication
date. Equal latest dates require an explicit publication qualifier. Malformed or dangling references
must be fixed before an OmenDB rebuild.

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
payload retains Foundry's stable `foundryID` for source-aware rebuilds. Spells are refreshed with
the rest of the corpus. `docs/player-core-spell-import-manifest.json` is an older, spell-only
accounting that is no longer regenerated.

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
- `action` (left out for a feat that isn't an action)

A feat has one `prerequisites` list. Each entry is its authored wording alone, or the wording
(`text`) with its machine-readable form beside it: one of the prerequisite cases defined in
`schemas/utility-types/rules.schema.json`:

```yaml
prerequisites:
- text: trained in Athletics
  hasSkillProficiency: {skill: athletics, proficiency: trained}
- text: You are wielding a ranged weapon
  unsupported: Unsupported prerequisite for source UiQ… "You are wielding a ranged weapon".
  diagnostic: true
```

When an importer cannot translate a source prerequisite, it records `unsupported` with its
explanation, and `diagnostic: true` when the explanation is also reported as a diagnostic (a string
gives a different diagnostic text); do not treat an unsupported condition as satisfied. A list is
typed in full or not at all. Record values in a typed form are `{type: core/feature-id, value:
'@class.bard.muses.maestro'}`.

Rules:

- Keep prerequisites human-readable but consistent.
- The converter parses common prerequisite strings into their typed form.
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
description: |
  A short source description of the archetype.
entryFeat: omen://archetype/bard/feats/bard-dedication?source=paizo-pathfinder-player-core
```

Use only source-backed root fields. Do not infer progression or configuration rules
from feat names; add those fields only when the source provides them.

The Player Core historical path map is recorded in `docs/migrations/player-core-0055-v1.0.0.json`.
Characters saved under the old identities are opened through it. The map is frozen; new moves go
through the migration tool and a reviewed refresh.

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
- A YAML convention changes through the schema first; the validator and the tools that read the
  archive change with it.

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

The manifest also declares resource identity beside each layout: a family sets
its OmenPath host and whether its layout owner is part of identity, and each
bundle child or custom group names its owned collection. A heritage's identity
includes its ancestry (`omen://ancestry/elf/heritages/seer-elf`).

Optional local hook:

```sh
./scripts/install-pre-commit.sh
```

Check before a rebuild:

- All YAML files are UTF-8.
- YAML parses.
- `./scripts/validate.sh` passes.
- Directory path matches the resource family, owner and slug.
- No `source` block (see "Source and attribution").
- `@` references and `omen://` paths resolve, e.g. a heritage's ancestry exists.

## Editing rules

- Keep files small and one resource per YAML file.
- Prefer explicit data over prose when a schema field exists.
- Do not store raw Foundry JSON in OmenArchive YAML.
- Do not use app/database IDs as resource identity.
- Identity is the publication-qualified OmenPath from the file's path; filename slugs stay stable.
- If a file cannot be represented cleanly, add a TODO/comment in the PR/commit, not an invalid schema workaround in the YAML.
