# spellcasting/increase-spell-proficiency

Increases the character's spell attack and spell DC proficiency, which every spellcasting source shares.

Effect `increase-spell-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `proficiency` | `proficiency-rank` | yes |

A character has one spell attack and spell DC proficiency rank, not one per tradition; each source keeps its own key attribute. The effect raises that rank and never lowers it.

## Usage in the archive

Used by 42 rules.

Example, from `paizo-pathfinder-player-core/archetype/ranger/feats/ranger-dedication.yml`:

```yaml
- key: dedication-spell-proficiency
  effect: spellcasting/increase-spell-proficiency
  inputs:
    proficiency: 2
```
