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
| `hasChoiceAncestryTrait`| Matches records sharing an ancestry chosen by a choice | `{ hasChoiceAncestryTrait: $.feat.adopted-ancestry.ancestry }` |
| `hasChoiceTradition` | Matches spells of a tradition selected by a choice | `{ hasChoiceTradition: $.gnome.wellspring-tradition }` |
| `knownBySource` | Matches spells known by a specific spellcasting source | `{ knownBySource: '@class.bard.features.bard-spellcasting#spellcasting-source' }` |
| `everything` | Wildcard match (matches all records) | `{ everything: true }` |
| `spell.category` | Spell category (`cantrip`, `spell`, `focus`, `ritual`) | `{ spell.category: cantrip }` |
| `spell.tradition` | Magical tradition (`arcane`, `divine`, `occult`, `primal`) | `{ spell.tradition: arcane }` |

## Negation (`not`)

The `not` operator accepts exactly one `trait` leaf:

```yaml
filter:
  all:
    - { type: feat }
    - { not: { trait: uncommon } }
```

No other negation shapes are permitted in epoch 2.
