# spellcasting/increase-source-proficiency

Increases the spell attack modifier and spell DC proficiency rank specifically for one spellcasting source.

Effect `increase-source-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `proficiency` | `proficiency-rank` | yes |

## Usage in the archive

Used by 26 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/legendary-spellcaster.yml`:

```yaml
- key: increase-source-proficiency-1
  effect: spellcasting/increase-source-proficiency
  level: 19
  inputs:
    sourceId: '@class.bard.features.bard-spellcasting#spellcasting-source'
    proficiency: 8
```
