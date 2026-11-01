# core/add-feature@2

Grants a class, ancestry, or general feature to the character by its canonical identifier.

Effect `add-feature`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `feature` | `feature-id` | yes |

## Usage in the archive

Used by 57 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/alchemy.yml`:

```yaml
- effect: core/add-feature@2
  inputs:
    feature: '@class.alchemist.alchemy-benefits.formula-book'
  key: grant-alchemy-benefits-formula-book
```
