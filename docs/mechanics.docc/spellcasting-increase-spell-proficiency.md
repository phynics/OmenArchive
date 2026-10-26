# spellcasting/increase-spell-proficiency

Increases general spell attack and spell DC proficiency across all traditions and spellcasting sources.

Effect `increase-spell-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `proficiency` | `proficiency-rank` | yes |

## Usage in the archive

Used by 12 rules.

Example, from `paizo-pathfinder-player-core/archetype/ranger/feats/ranger-dedication.yml`:

```yaml
- key: dedication-spell-proficiency
  effect: spellcasting/increase-spell-proficiency
  inputs:
    proficiency: 2
```
