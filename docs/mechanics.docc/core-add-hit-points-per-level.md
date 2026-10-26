# core/add-hit-points-per-level

Grants additional Hit Points for every character level gained.

Effect `add-hit-points-per-level`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `amount` | `int` | yes |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core/feat/toughness.yml`:

```yaml
- key: flat-modifier-1
  effect: core/add-hit-points-per-level
  inputs:
    amount: 1
```
