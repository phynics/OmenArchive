# core/add-speed-modifier

Applies a permanent bonus or penalty in feet to the character's land Speed.

Effect `add-speed-modifier`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `amount` | `int` | yes |

## Writes

- domain `speed`, name `speed`

## Usage in the archive

Used by 5 rules.

Example, from `paizo-pathfinder-player-core/feat/nimble-hooves.yml`:

```yaml
- key: add-speed-modifier-1
  effect: core/add-speed-modifier
  inputs:
    amount: 5
```
