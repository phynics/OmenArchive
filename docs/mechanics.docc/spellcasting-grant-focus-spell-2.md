# spellcasting/grant-focus-spell@2

Grants a focus spell to a spellcasting source and establishes its focus cantrip or focus spell scaling.

Effect `grant-focus-spell`, revision 2, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spell` | `spell-id` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 121 rules.

Example, from `paizo-pathfinder-player-core-2/class/champion/features/devotion-spells.yml`:

```yaml
- effect: spellcasting/grant-focus-spell@2
  inputs:
    source: champion-focus-spells
    spell:
      choice: $.champion.devotion-spell
  key: grant-devotion-spell
```
