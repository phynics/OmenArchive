# core/add-saving-throw

Sets or improves the character's proficiency rank in Fortitude, Reflex, or Will saving throws.

Effect `add-saving-throw`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `savingThrow` | `saving-throw` | yes |
| `proficiencyRank` | `proficiency-rank` | yes |

## Writes

- domain `saving-throw`, name input `savingThrow`

## Usage in the archive

Used by 73 rules.

Example, from `paizo-pathfinder-player-core/class/fighter/features/battle-hardened.yml`:

```yaml
- key: add-saving-throw-1
  effect: core/add-saving-throw
  inputs:
    savingThrow: fortitude
    proficiencyRank: 6
```
