# spellcasting/increase-spell-proficiency@2

Increases the character's spell attack and spell DC proficiency, which every spellcasting source shares.

Effect `increase-spell-proficiency`, revision 2, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `rank` | `proficiency-rank` | yes |

## Usage in the archive

Used by 42 rules.

Example, from `paizo-pathfinder-player-core-2/archetype/beastmaster/feats/beastmaster-dedication.yml`:

```yaml
- effect: spellcasting/increase-spell-proficiency@2
  inputs:
    rank: trained
  key: dedication-spell-proficiency
```
