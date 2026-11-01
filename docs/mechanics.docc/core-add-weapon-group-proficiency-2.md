# core/add-weapon-group-proficiency@2

Grants proficiency in an entire weapon group. When includeAdvanced is true, also grants advanced weapons in that group.

Effect `add-weapon-group-proficiency`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weaponGroup` | `weapon-group` | yes |
| `rank` | `proficiency-rank` | yes |
| `includeAdvanced` | `bool` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/class/fighter/features/fighter-weapon-mastery.yml`:

```yaml
- effect: core/add-weapon-group-proficiency@2
  inputs:
    includeAdvanced: false
    rank: master
    weaponGroup:
      choice: $.fighter.weapon-mastery-group
  key: martial-proficiency-1
```
