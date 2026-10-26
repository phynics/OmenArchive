# core/add-weapon-proficiency

Grants proficiency in a weapon category or specific weapon. When selfScaling is true, the rank automatically scales up when the character's general weapon proficiency advances.

Effect `add-weapon-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weaponDesignation` | `weapon-designation` | yes |
| `proficiencyRank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 87 rules.

Example, from `paizo-pathfinder-player-core/class/fighter/features/versatile-legend.yml`:

```yaml
- key: generated-1
  effect: core/add-weapon-proficiency
  inputs:
    weaponDesignation: {kind: filter, weaponGroup: any, weaponKind: advanced}
    proficiencyRank: 6
    selfScaling: false
```
