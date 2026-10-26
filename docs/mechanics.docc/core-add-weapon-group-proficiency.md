# core/add-weapon-group-proficiency

Grants proficiency in an entire weapon group. When includeAdvanced is true, also grants advanced weapons in that group.

Effect `add-weapon-group-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weaponGroup` | `weapon-group` | yes |
| `proficiencyRank` | `proficiency-rank` | yes |
| `includeAdvanced` | `bool` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/class/fighter/features/fighter-weapon-mastery.yml`:

```yaml
- key: martial-proficiency-1
  effect: core/add-weapon-group-proficiency
  inputs:
    weaponGroup: {choice: $.fighter.weapon-mastery-group}
    proficiencyRank: 6
    includeAdvanced: false
    selfScaling: false
```
