# core/add-chosen-weapon-proficiency@2

Grants proficiency in the chosen deity's favored weapon, scaling with the character's weapon training.

Effect `add-chosen-weapon-proficiency`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weapon` | `weapon-reference` | yes |
| `rank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core-2/class/champion/deity-benefits/deific-weapon.yml`:

```yaml
- effect: core/add-chosen-weapon-proficiency@2
  inputs:
    rank: trained
    selfScaling: true
    weapon:
      choice: $.deity.favored-weapon
  key: deity-favored-weapon-proficiency
```
