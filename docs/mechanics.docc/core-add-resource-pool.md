# core/add-resource-pool

Declares a resource the player spends and refills by hand, with a maximum that grows with the character and an optional item level (Versatile Vials).

Effect `add-resource-pool`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `name` | `string` | yes |
| `maximum` | `sheet-value` | yes |
| `itemLevel` | `sheet-value` | no |

## Writes

- domain `resource-pool`, name input `name`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/alchemy-benefits/versatile-vials.yml`:

```yaml
- effect: core/add-resource-pool
  inputs:
    itemLevel: \[[$.level]]
    maximum: \[[(add 2 $.attributes.int)]]
    name: versatile-vials
  key: versatile-vials-pool
```
