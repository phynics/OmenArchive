# core/add-resource-pool

Declares a resource the player spends and refills, with a maximum that grows with the character: Versatile Vials (with an item level), or a daily crafting pool such as Cauldron (refresh: daily, craftable: the items a use can make). A manual pool refills by hand; a daily one refills with the daily preparations.

Effect `add-resource-pool`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `name` | `string` | yes |
| `maximum` | `sheet-value` | yes |
| `itemLevel` | `sheet-value` | no |
| `refresh` | `string` | no |
| `craftable` | `resource-filter` | no |

## Writes

- domain `resource-pool`, name input `name`

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core-2/archetype/alchemist/feats/advanced-alchemy.yml`:

```yaml
- effect: core/add-resource-pool
  inputs:
    craftable:
      all:
      - trait: alchemical
      - trait: consumable
    maximum: 4
    name: advanced-alchemy
    refresh: daily
  key: advanced-alchemy-resource-pool
```
