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
  rank: expert
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
- **One effect per concept.** `add-feature {feature}` and `add-heritage {heritage}` grant a record by reference (or
  by a choice); `add-trait {trait, as?: ancestry}` grants a trait; `add-speed {movement, speed | bonus}` sets a
  movement type (`land`, `climb`, `swim`, `fly`, `burrow`) or adds a bonus to land Speed; `add-sense {sense, acuity?,
  range?}` grants a sense.
- **Hit points are one effect.** `add-hit-points {amount}` takes a number or an expression, worked out for the level
  shown: `amount: 4`, `amount: $.level` (a bonus for each level), `amount: (multiply 3 $.archetype.fighter.feat-count)` (a bonus
  for each feat from an archetype).
- **Prerequisites name a record by `has`.** `has: '@feat.aggressive-block'` is met when the character has that
  record: a feat, a class feature, a heritage, an action or an identity record. A name never stands for a record
  (`hasFeatWithName` and its kin are gone). A spell or an item is never "had", so a `has` on one is never met.
- **Record inputs** are named by their role, not their type: `feat:`, `feature:`, `heritage:`, `spell:`, `item:`,
  `action:` (never `featId`), each taking an `@` reference.
- **Ranks.** A proficiency rank is a word (`untrained`, `trained`, `expert`, `master` or `legendary`) under one input
  name, `rank`, on every effect that takes one: `rank: expert`. `add-skill-increase {skill, rank}` raises the skill to
  `rank`. A number is not a rank, and `rank` means only a proficiency rank: a spell's rank keeps the names
  `spellRank` and `rankPolicy`.
- **Attributes** are spelled out: `attribute: wisdom`, `keyAttribute: strength`, `cases: [strength, dexterity]` in an
  attribute choice, and `hasAttributeModifier: {attribute: strength, modifier: 2}` in a prerequisite. The decoded wire
  form (`omen-archive wire`) keeps the abbreviations (`wis`), because the answer to an attribute question in a saved
  character holds one.
- **Kinds without data** are a word: `skill: arcana`, `rankPolicy: cantrip`, `castFrequency: atWill`.
- **Kinds with one datum** are a one-key map from the kind to the datum: `{lore: Boneyard Lore}`,
  `{fixed: 4}` (the rank), `{perDay: 1}` (the uses), `{rank: 1}` and `{upTo: 3}` (what a spell pick takes;
  a cantrip pick is the word `cantrip`). A list of such values is a list of these
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
`condition: ''` (`add-play-note`) and `exceptions: ''` (`add-resistance`). An optional input has no default: it is
absent when the rule doesn't use it (`add-sense`'s `acuity` and `range`, `add-speed`'s `speed` and `bonus`,
`add-trait`'s `as`).

### Explicit forms and escapes

- `{ choice: $.cleric.divine-font }`: reads the chosen answer from a named character choice.
- `{ choiceList: $.deity.spells }`: reads a list of answers from a multi-select choice.
- `{ choice: $.cleric.domains, field: domainSpell }`: reads a field of the record the choice holds (here a
  domain), not the record itself. The field's value must match the input's value type: `domainSpell` and
  `advancedDomainSpell` are spell references, so they fill a `spell-id` input. The rule waits until the choice
  is answered; a record without that field applies nothing and reports it. On the wire the source is
  `{kind: choiceField, name: $.cleric.domains, field: domainSpell}`. `field` is allowed only with `choice`.
- `$.cleric.domains.domainSpell`: the short form of that field read, for a choice that holds one answer. A
  bare `$` path on an input that isn't a sheet value is a field read exactly when its last segment is one of
  the readable field names (`domainSpell`, `advancedDomainSpell`); the path before it names the choice
  (`$.cleric.advanced-domains.advancedDomainSpell` reads the field of `$.cleric.advanced-domains`). Any other
  bare `$` path on such an input is an error, and a choice is never named after a readable field. The writer
  uses the short form where it reads back to the same source, and the long form is always accepted.
- `{ literal: ... }`: only an escape, for a payload that is itself a map whose keys are all `type` or a
  source key. A map that merely has a `type` key (`numeric: {amount: 1, type: item}`) is written bare.
- `{ type: core/skill, … }`: names the input's value type where it isn't the one the descriptor declares.

- `{ list: $.deity.spells, field: rank }`: reads one field of every item of a character list, as a list of values in list
  order. `$.deity.spells[].rank` is its short form, for an input that takes a list. See [Character
  lists](character-lists.md#reading-a-list).
- `{ entry: { rank: { type: core/int, value: 1 } } }`: one entry of an entry list, each field a value with its type.

An input that names a character list (`declare-list` and `add-to-list`'s `list`) is written as its plain `$` path:
`list: $.feats.assurance.skills`. It needs no backslash, and `[]` is refused there. An item added to a list is
`{ choice: $.path }` or a value with its type (`{ type: core/skill, literal: athletics }`), which the list's
declaration then checks.

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
- **`distinct`**: Leaves out the value of one or more `$` paths: another choice or a built-in. One path is bare, `distinct: $.ancestry.name`; several are a list, `distinct: [$.bard.muse, $.feat.other]`. It is one-way: the choice it names keeps its own options. An unanswered path leaves out nothing. `{list: $.path}` leaves out the items on a [character list](character-lists.md), and `distinct: false` goes with `addTo`.
- **`addTo`**: Names the character list the answer goes to (`addTo: $.feats.assurance.skills`). The reader expands it into an `add-to-list` rule keyed `<question key>-add` and a `distinct` over the same list; the wire form carries only those rules. See [Character lists](character-lists.md#addto-on-a-question).
- **`optional: true`**: Marks the choice as optional, excluding it from blocking open-question counts.

The older spellings stay readable: `records: { filter: …, type: … }`, `freeText: core/string`, and `optionsFrom` beside `records`.

For complete documentation on all registered effects, see the native DocC catalog in `docs/mechanics.docc/`.
