# core/add-formulas

Teaches alchemical crafting formulas for every grade of the listed items.

Effect `add-formulas`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `items` | `item-id-list` | yes |

## Usage in the archive

Used by 25 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/alchemy-benefits/formula-book.yml`:

```yaml
- effect: core/add-formulas
  inputs:
    items:
      choiceList: $.alchemist.formulas.starting
  key: learn-choice-alchemist-formulas-starting
```
