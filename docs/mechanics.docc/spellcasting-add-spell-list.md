# spellcasting/add-spell-list

Expands a spellcasting source's available spell list with an additional list of spells.

Effect `add-spell-list`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spells` | `spell-id-list` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 9 rules.

Example, from `paizo-pathfinder-player-core/class/cleric/features/deity-cleric.yml`:

```yaml
- key: deity-spell-list-rank-1
  effect: spellcasting/add-spell-list
  inputs:
    source: cleric-spellcasting
    spells: {choiceList: $.deity.spells.rank-1}
```
