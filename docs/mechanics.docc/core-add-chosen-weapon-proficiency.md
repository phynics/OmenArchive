# core/add-chosen-weapon-proficiency

Grants proficiency in the chosen deity's favored weapon, scaling with the character's weapon training.

Effect `add-chosen-weapon-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weapon` | `weapon-reference` | yes |
| `proficiencyRank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core/class/cleric/features/deity-cleric.yml`:

```yaml
- key: deity-favored-weapon-proficiency
  effect: core/add-chosen-weapon-proficiency
  inputs:
    weapon: {choice: $.deity.favored-weapon}
    proficiencyRank: 2
    selfScaling: true
```
