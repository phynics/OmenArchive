# spellcasting/add-known-spell-list

Adds multiple spells simultaneously to both a spellcasting source's spell list and its known repertoire.

Effect `add-known-spell-list`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spells` | `spell-id-list` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

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
    source: oracle-spellcasting
    spells: {choiceList: $.deity.spells.rank-1}
```
