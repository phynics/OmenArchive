# Rules and Effect Inputs

This document details the structure of `rules:` blocks, effect invocations, bare vs. explicit inputs, and player choices in OmenArchive.

## Overview

The `rules:` array is used on feats, features, ancestries, heritages, and backgrounds to modify character game state or prompt player selections.

- **Classes**: Classes never define inline `rules:`. All class mechanics reside in dedicated feature files under `features/` or custom group directories.
- **Ancestries, Heritages, Backgrounds**: Apply inline rules at 1st level.
- **Feats and Features**: Apply rules at the feat's level or when configured by `level:`.
- **Omission**: Omit the `rules:` key entirely when a record has no mechanical effects. Do not commit empty arrays (`rules: []`).

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

A `sourceId` identifying a spellcasting source is authored as a reference to the defining feature:
`sourceId: '@class.wizard.features.wizard-spellcasting#spellcasting-source'`.

## Input Values: Bare Literals vs. Explicit Forms

The schema and mechanics descriptors define the expected input types, allowing most values to be authored as bare literals:

```yaml
inputs:
  proficiencyCap: 2
  skill: { kind: deception }
```

### Explicit Value Forms

When an input requires dynamic evaluation or complex data, use the explicit object forms:
- `{ choice: $.cleric.divine-font }`: Reads the chosen answer from a named character choice.
- `{ choiceList: $.deity.spells }`: Reads a list of answers from a multi-select choice.
- `{ literal: ... }`: Escapes a payload that might otherwise resemble an expression or choice path.

Strings beginning with `$`, `@`, `(`, or `[[` must be escaped with a leading backslash (`\$5`).

## Player Choices (`choice:`)

A choice rule prompts the player for a decision. It uses `choice:` instead of `effect:` and `inputs:`:

```yaml
rules:
  - key: choice-cleric-divine-font
    choice:
      name: $.cleric.divine-font
      label: Divine Font
      type: spellcasting/spell-id
      cases:
        - { value: '@spell.heal' }
        - { value: '@spell.harm' }
```

### Choice Properties

- **`name`**: A `$.` path naming the shared question across the character.
- **`label`**: Human-readable prompt shown in character builders.
- **`type`**: Registered type of the answers (e.g. `core/skill`, `spellcasting/spell-id`).
- **Options**: Defined using one of:
  - `cases`: An explicit list of `{ value: ... }` items. Cases may also carry `effects:` that apply when selected.
  - `records`: A query object `{ filter: { ... }, type: ... }` dynamically populated from the archive.
  - `freeText`: Accepts arbitrary text typed by the player (e.g. edicts/anathema).
- **`multiple`**: Specifies multi-selection: `multiple: { min: 1, max: 3 }`.
- **`optionsFrom`**: Limits options to the values selected in another choice: `optionsFrom: $.deity.domains`.
- **`distinctWithin`**: Prevents duplicate picks within a named group (such as spells in a single spellbook).
- **`optional: true`**: Marks the choice as optional, excluding it from blocking open-question counts.

For complete documentation on all registered effects, see the native DocC catalog in `docs/mechanics.docc/`.
