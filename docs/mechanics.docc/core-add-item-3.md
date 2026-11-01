# core/add-item@3

Grants physical equipment or inventory items to the character.

Effect `add-item`, revision 3, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `entryId` | `uuid` | yes |
| `item` | `item-id` | yes |
| `quantity` | `int` | yes |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/alchemy-benefits/formula-book.yml`:

```yaml
- effect: core/add-item@3
  inputs:
    entryId: ff9e4d0d-a229-54a6-b65c-e0255259034e
    item: '@item.formula-book-blank?source=paizo-pathfinder-player-core'
    quantity: 1
  key: free-formula-book
```
