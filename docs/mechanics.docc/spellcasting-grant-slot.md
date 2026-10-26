# spellcasting/grant-slot

Grants one or more spell slots of a specific spell rank to a spellcasting source.

Effect `grant-slot`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `spellRank` | `int` | yes |
| `count` | `int` | yes |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core-2/feat/oracular-providence.yml`:

```yaml
- key: grant-slot-1
  effect: spellcasting/grant-slot
  level: 20
  inputs:
    sourceId: '@class.oracle.features.oracle-spellcasting#spellcasting-source'
    spellRank: 10
    count: 1
```
