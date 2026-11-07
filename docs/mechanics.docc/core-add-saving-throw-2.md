# core/add-saving-throw@2

Sets or improves the character's proficiency rank in Fortitude, Reflex, or Will saving throws.

Effect `add-saving-throw`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `savingThrow` | `saving-throw` | yes |
| `rank` | `proficiency-rank` | yes |

## Writes

- domain `saving-throw`, name input `savingThrow`

## Usage in the archive

Used by 73 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/chemical-hardiness.yml`:

```yaml
- effect: core/add-saving-throw@2
  inputs:
    rank: master
    savingThrow: fortitude
  key: fortitude-master
  level: 11
```
