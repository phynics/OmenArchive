# spellcasting/add-spell-list

Expands a spellcasting source's available spell list with an additional list of spells.

Effect `add-spell-list`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `spells` | `spell-id-list` | yes |

## Usage in the archive

Used by 9 rules.

Example, from `paizo-pathfinder-player-core/class/cleric/features/deity-cleric.yml`:

```yaml
- key: deity-spell-list-rank-1
  effect: spellcasting/add-spell-list
  inputs:
    sourceId: '@class.cleric.features.cleric-spellcasting#spellcasting-source'
    spells: {choiceList: $.deity.spells.rank-1}
```
