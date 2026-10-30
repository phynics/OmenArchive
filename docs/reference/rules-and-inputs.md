# Rules and Effect Inputs

This document details the structure of `rules:` blocks, effect invocations, bare vs. explicit inputs, and player choices in OmenArchive.

## Overview

The `rules:` array is used on feats, features, ancestries, heritages, and backgrounds to modify character game state or prompt player selections.

- **Classes**: Classes never define inline `rules:`. All class mechanics reside in dedicated feature files under `features/` or custom group directories.
- **Ancestries, Heritages, Backgrounds**: Apply inline rules at 1st level.
- **Feats and Features**: Apply rules at the feat's level or when configured by `level:`.
- **Omission**: Omit the `rules:` key entirely when a record has no mechanical effects. Do not commit empty arrays (`rules: []`), here or anywhere in a record: the archive check rejects an empty array, and the reader puts back the empty lists the stored form needs.

## Rule Structure

A rule contains the following fields in order:

```yaml
rules:
  - key: add-language-draconic
    effect: core/add-language
    level: 3                 # Omitted when 1
    prerequisites:
      - hasClassTrait: true
    inputs:
      languageName: Draconic
```

- **`key`**: Unique kebab-case string within the record. A rule's identity UUID is deterministically derived from its enclosing record path and key: `uuid5("<record-path>#rule/<key>")`. Renaming a key constitutes creating a new rule.
- **`effect`**: `<module-alias>/<effect-name>`, optionally with `@<revision>` if different from 1 (e.g. `core/add-feat@2`). Module aliases are declared in `publication.yml`.
- **`level`**: The level at which the rule takes effect (defaults to 1 if omitted).
- **`prerequisites`**: Optional list of typed prerequisite conditions.
- **`inputs`**: Map of input parameter names to their values as declared by the effect's descriptor.

## Derived Identity Inputs

Inputs that uniquely identify the rule itself (such as `selectionId`, `grantId`, or `uuid`) are tagged with `identity: rule` in the mechanics descriptor and are **omitted from the authored YAML**. The engine derives them deterministically from the record path and rule key:
`uuid5("<record-path>#rule/<key>/<input-name>")`.

An input that names a spellcasting source is written `source` and takes the source's **key**, such as
`source: wizard-spellcasting` or `source: ranger-focus-spells`. The key is kebab-case after the source's
name (the `sourceName` of its `configure-source` rule, or the name of the feature that defines it), and
the publication declares it in `spellcastingSources` of `publication.yml`, where it is mapped to the
source's ID. The wire form calls the input `sourceId` and holds that ID; a literal source ID is not
written in a record. See [Spellcasting Tables and Sources](spellcasting.md#source-keys).

## Input Values

The mechanics descriptor gives every input a value type, and the reader parses the authored value
through that type. An input is written as the plainest value of its type; none of the wire form's
`payload`, `revision`, `typeID` or `kind` wrappers appear.

```yaml
inputs:
  proficiencyCap: 2
  skill: arcana                             # a skill: a word
  rankPolicy: {fixed: 4}                    # a kind with one datum: {kind: datum}
  castFrequency: focus
  maximum: (max 1 (divide $.level 2))       # a sheet value: a bare expression
  itemLevel: $.item.level                   #   or a bare $ path
```

### Typed values

- **Sheet values.** An input whose type is a sheet value (`maximum`, `itemLevel`, a resistance's `value`) takes a
  bare expression, which starts with `(` and ends with `)`, or a bare `$` path. Numbers are written
  as numbers.
- **Kinds without data** are a word: `skill: arcana`, `rankPolicy: cantrip`, `castFrequency: atWill`.
- **Kinds with one datum** are a one-key map from the kind to the datum: `{lore: Boneyard Lore}`,
  `{fixed: 4}` (the rank), `{perDay: 1}` (the uses). A list of such values is a list of these
  (`[arcana, {lore: Y}]`). A type with more than one datum (a weapon or armor designation) keeps
  its `{kind: filter, weaponGroup: …}` form.
- **Filters.** An input that takes a resource filter is written like the filters under `choice:`
  (`{all: [{type: feat}, {trait: gnome}]}`); the wire's `{kind: intersection, values: […]}` wrapper is
  only read.
- **Grant settings.** The `with:` input of `core/add-feat@2` maps a `$` path to a setting. A setting
  is the value it grants: a bare value is a **skill** (`$.feat.assurance.skills: athletics`), and a value of
  any other type is spelled with its type (`{type: core/terrain, value: underground}`, the same
  spelling `type:` has anywhere). The two other settings are `{from: [arcana, nature]}`, which
  offers values, and `{choice: $.feat.gnome-obsession.lore}`, which reads a choice (with
  `as: lore`, a lore skill named by the answer).

### Left-out inputs

An input that holds its default is left out, and the reader puts it back. The defaults are
`selfScaling: false` (every proficiency effect), `mode: add` and `condition: ''` (`add-play-modifier`),
`condition: ''` (`add-play-note`), `exceptions: ''` (`add-resistance`), and `acuity: ''` and `range: -1`
(`add-sense`, where no `range` means no range).

### Explicit forms and escapes

- `{ choice: $.cleric.divine-font }`: reads the chosen answer from a named character choice.
- `{ choiceList: $.deity.spells }`: reads a list of answers from a multi-select choice.
- `{ literal: ... }`: only an escape, for a payload that is itself a map whose keys are all `type` or a
  source key. A map that merely has a `type` key (`numeric: {amount: 1, type: item}`) is written bare.
- `{ type: core/skill, … }`: names the input's value type where it isn't the one the descriptor declares.

An input whose type is **text** (`string`, as in `add-membership`'s `list`) takes a `$` path or an
expression as plain text, so a string that begins with `$`, `@`, `(` or `[[` is escaped with a
leading backslash (`\$.druid.order-memberships`). No other type needs the backslash.

## Player Choices (`choice:`)

A choice rule prompts the player for a decision. It uses `choice:` instead of `effect:` and `inputs:`:

```yaml
rules:
  - key: choice-cleric-divine-font
    choice:
      name: $.cleric.divine-font
      label: Divine Font
      type: spellcasting/spell-id
      cases: ['@spell.heal', '@spell.harm']
```

### Choice Properties

- **`name`**: A `$.` path naming the shared question across the character.
- **`label`**: Human-readable prompt shown in character builders.
- **`type`**: Registered type of the answers (e.g. `core/skill`, `spellcasting/spell-id`), always on the choice. A choice whose cases carry no value has no type.
- **Options**: Defined using one of:
  - `cases`: A list of the values: `cases: [strength, dexterity]`. The case's key is the value's text. A case with a label, a different key or `effects:` is a map (`{ key: …, label: …, value: …, effects: […] }`), and then the list is maps.
  - `records`: A query object `{ filter: { ... } }` dynamically populated from the archive, with the answers' `type:` on the choice. `records: { filter: …, from: $.deity.domains }` limits the options to the values selected in another choice.
  - `freeText: true`: Accepts arbitrary text typed by the player (e.g. edicts/anathema), of the choice's `type`.
- **`multiple`**: Specifies multi-selection: `multiple: { min: 1, max: 3 }`.
- **`optionsFrom`**: The same limit on a choice with `cases`: `optionsFrom: $.deity.divine-font`. On a `records` choice it is written `records: { from: … }`.
- **`distinctWithin`**: Prevents duplicate picks within a named group (such as spells in a single spellbook).
- **`optional: true`**: Marks the choice as optional, excluding it from blocking open-question counts.

The older spellings stay readable: `records: { filter: …, type: … }`, `freeText: core/string`, and `optionsFrom` beside `records`.

For complete documentation on all registered effects, see the native DocC catalog in `docs/mechanics.docc/`.
