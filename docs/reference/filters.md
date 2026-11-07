# Resource Filters

This document specifies the syntax and semantics of resource queries used in choices and rule prerequisites in OmenArchive.

## Filter Syntax

A resource filter is expressed as a leaf condition or as a boolean combination using `all` or `any`:

```yaml
options:
  filter:
    all:
      - { type: spell }
      - { spell.category: cantrip }
      - { spell.tradition: arcane }
      - { rarity: common }
```

Filters fitting within 56 characters may be written inline on a single line. Longer filters place each sub-filter on its own line.

## Supported Filter Keys

| Key | Description | Example |
| :--- | :--- | :--- |
| `type` | Resource family type (`feat`, `spell`, `action`, etc.) | `{ type: feat }` |
| `rarity` | Rarity tier (`common`, `uncommon`, `rare`, `unique`) | `{ rarity: common }` |
| `level` | Exact level match | `{ level: 1 }` |
| `maxLevel` | Upper bound for level (inclusive) | `{ maxLevel: 3 }` |
| `name` | Exact record name | `{ name: "trip" }` |
| `trait` | Presence of a game trait | `{ trait: concentrate }` |
| `id` | Exact record reference | `{ id: '@feat.nimble-dodge' }` |
| `excludesIds` | List of record references to exclude | `{ excludesIds: ['@feat.shield-block'] }` |
| `pathPrefix` | Scopes options to a collection directory | `{ pathPrefix: '@class.witch.patrons' }` |
| `sharesAncestryTrait` | Matches records sharing the character's ancestry trait | `{ sharesAncestryTrait: true }` |
| `sharesClassTrait` | Matches records sharing the character's class trait | `{ sharesClassTrait: true }` |
| `characterHasFeat` | Tests whether the character has taken a specific feat | `{ characterHasFeat: '@feat.assurance' }` |
| `hasChoiceAncestryTrait`| Matches records sharing an ancestry chosen by a choice | `{ hasChoiceAncestryTrait: $.feats.adopted-ancestry.ancestry }` |
| `requiresListValue` | Matches records whose structured prerequisites test a character list for the value a question holds ("a feat that requires that order"). Text-only prerequisites never match | `{ requiresListValue: { list: $.druid.orders, value: { choice: $.feats.order-explorer.order } } }` |
| `hasChoiceTradition` | Matches spells of a tradition selected by a choice | `{ hasChoiceTradition: $.gnome.wellspring-tradition }` |
| `knownBySource` | Matches spells known by a specific spellcasting source | `{ knownBySource: bard-spellcasting }` |
| `hasSourceTradition` | Matches spells of the tradition a spellcasting source is configured with | `{ hasSourceTradition: witch-spellcasting }` |
| `fact.<name>` | From format 6. Matches records that state the fact `<name>` with this value, or whose value is on a character list (see below). A record that states no such fact never matches | `{ fact.tier: expert }`, `{ fact.tier: { in: $.commander.tiers } }` |
| `everything` | Wildcard match (matches all records) | `{ everything: true }` |
| `spell.category` | Spell category (`cantrip`, `spell`, `focus`, `ritual`) | `{ spell.category: cantrip }` |
| `spell.tradition` | Magical tradition (`arcane`, `divine`, `occult`, `primal`) | `{ spell.tradition: arcane }` |

## Facts (from format 6)

A record can state facts about itself under `facts:`, and a publication declares each fact once for a collection, with its type: a whole number, a flag, a term of a vocabulary, a reference to a record, or a list of these. A filter can test a fact in two ways:

```yaml
filter:
  all:
    - { type: feat }
    - { pathPrefix: '@class.commander.tactics' }
    - { fact.tier: expert }                          # the record states tier: expert
    - { fact.tier: { in: $.commander.tiers } }       # the record's tier is on the character list $.commander.tiers
```

- The value has the fact's type: a term of its vocabulary, a number, `true` or `false`, or an `@` reference to a record of the declared collection. A fact whose type is a list matches a value it holds, and matches a list when it holds any of the list's items.
- The `in` form names a character list by its `$` path. A list that nothing has added to is empty, so it matches nothing.
- The records the filter offers must declare the fact. Name them with a `pathPrefix` or a `type` in the same `all`; the validator refuses a fact that none of them declares, a value of another type, and a list whose items are of another type.
- A key that starts with `fact.` is always a fact. To filter on a metadata key with that spelling, use the long form `{ metadata: { key: fact.tier, value: expert } }`.

## Negation (`not`)

The `not` operator accepts exactly one `trait` leaf:

```yaml
filter:
  all:
    - { type: feat }
    - { not: { trait: uncommon } }
```

No other negation shapes are permitted in epoch 2.
