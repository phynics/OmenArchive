# core/add-weapon-proficiency@2

Grants proficiency in a weapon category or specific weapon. When selfScaling is true, the rank automatically scales up when the character's general weapon proficiency advances.

Effect `add-weapon-proficiency`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weaponDesignation` | `weapon-designation` | yes |
| `rank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 87 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/alchemical-weapon-expertise.yml`:

```yaml
- effect: core/add-weapon-proficiency@2
  inputs:
    rank: expert
    weaponDesignation:
      kind: filter
      weaponGroup: any
      weaponKind: simple
  key: alchemical-weapons-simple
  level: 7
```
