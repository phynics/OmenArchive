# spellcasting/grant-slot

Grants one or more spell slots of a specific spell rank to a spellcasting source.

Effect `grant-slot`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spellRank` | `int` | yes |
| `count` | `int` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core-2/feat/bloodline-perfection.yml`:

```yaml
- effect: spellcasting/grant-slot
  inputs:
    count: 1
    source: sorcerer-spellcasting
    spellRank: 10
  key: rank-10-slot
  level: 20
```
