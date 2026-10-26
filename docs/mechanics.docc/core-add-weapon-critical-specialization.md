# core/add-weapon-critical-specialization

Unlocks the critical specialization effect for all weapons within a weapon group.

Effect `add-weapon-critical-specialization`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `uuid` | `uuid` | yes |
| `weaponGroup` | `weapon-group` | yes |

Derived from the rule key, never written: `uuid`.

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 5 rules.

Example, from `paizo-pathfinder-player-core/class/ranger/features/ranger-weapon-expertise.yml`:

```yaml
- key: add-weapon-critical-specialization-1
  effect: core/add-weapon-critical-specialization
  inputs:
    weaponGroup: any
```
