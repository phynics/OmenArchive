# spellcasting/increase-proficiency

Increases spell attack and spell DC proficiency for all spells belonging to a specific magical tradition.

Effect `increase-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `tradition` | `tradition` | yes |
| `proficiency` | `proficiency-rank` | yes |

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core-2/feat/advanced-qi-spells.yml`:

```yaml
- key: qi-spell-proficiency
  effect: spellcasting/increase-proficiency
  inputs:
    tradition: {choice: $.qi.tradition}
    proficiency: 2
```
