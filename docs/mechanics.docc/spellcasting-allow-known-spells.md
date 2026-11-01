# spellcasting/allow-known-spells

Lets the player pick a number of spells for a spellcasting source's repertoire or spellbook in its collection editor; grants none itself.

Effect `allow-known-spells`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `count` | `int` | yes |
| `pick` | `spell-pick` | yes |
| `filter` | `resource-filter` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `wizard-spellcasting`. The wire form calls the input `sourceId` and holds the source's ID.

`pick` is what the spells are: the word `cantrip`, `{rank: 1}` for spells of exactly that rank, or `{upTo: 3}` for spells of any rank up to the rank given. `filter` is the records the picks come from: the tradition or patron list and the rarity. The rule starts at its `level`. It adds no spell; the player's picks fill it.

## Usage in the archive

Used by 0 rules written out. The 165 rules in the archive come from `spellcasting:` blocks, which write one rule for each level and kind of pick.

Example:

```yaml
- key: allow-known-spells-1
  effect: spellcasting/allow-known-spells
  level: 3
  inputs:
    source: wizard-spellcasting
    count: 2
    pick: {upTo: 2}
    filter:
      all:
      - {type: spell}
      - {spell.tradition: arcane}
      - {rarity: common}
```
