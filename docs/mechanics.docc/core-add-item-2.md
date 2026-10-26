# core/add-item@2

Grants physical equipment or inventory items to the character.

Effect `add-item`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `entryId` | `uuid` | yes |
| `itemId` | `item-id` | yes |
| `quantity` | `int` | yes |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core/ancestry/dwarf/features/clan-dagger.yml`:

```yaml
- key: free-clan-dagger
  effect: core/add-item@2
  inputs:
    entryId: 71ae7a29-94de-5378-aea3-cb6f2a536950
    itemId: '@item.clan-dagger'
    quantity: 1
```
