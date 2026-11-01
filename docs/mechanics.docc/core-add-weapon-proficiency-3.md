# core/add-weapon-proficiency@3

Grants proficiency in weapons: a category and group filter, a weapon group the player chose (with a category that leaves out advanced weapons, say), or one weapon. When selfScaling is true, the rank automatically scales up when the character's general weapon proficiency advances.

Effect `add-weapon-proficiency`, revision 3, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weapons` | `list-item` | yes |
| `rank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |
| `category` | `weapon-kind` | no |

## Writes

- domain `weapon-proficiency`, name `weapon`

## Usage in the archive

Used by 93 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/alchemical-weapon-expertise.yml`:

```yaml
- effect: core/add-weapon-proficiency@3
  inputs:
    rank: expert
    weapons:
      category: simple
  key: alchemical-weapons-simple
  level: 7
```
