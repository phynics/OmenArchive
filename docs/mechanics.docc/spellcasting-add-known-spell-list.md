# spellcasting/add-known-spell-list

Adds multiple spells simultaneously to both a spellcasting source's spell list and its known repertoire.

Effect `add-known-spell-list`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `spells` | `spell-id-list` | yes |

## Usage in the archive

Used by 9 rules.

Example, from `paizo-pathfinder-player-core-2/class/oracle/features/divine-access.yml`:

```yaml
- key: divine-access-rank-1
  effect: spellcasting/add-known-spell-list
  level: 11
  prerequisites:
  - hasChoice:
      name: $.oracle.divine-access
      contains: {type: core/int, value: 1}
  inputs:
    sourceId: '@class.oracle.features.oracle-spellcasting#spellcasting-source'
    spells: {choiceList: $.deity.spells.rank-1}
```
