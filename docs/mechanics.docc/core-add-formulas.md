# core/add-formulas

Teaches alchemical crafting formulas for every grade of the listed items.

> **Removed in format 6.** A format 6 reader refuses this effect. Write a rule with `forEach` over the list of the question it read, adding `{item: true}` to `$.crafting.formulas`, instead.

Effect `add-formulas`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `items` | `item-id-list` | yes |

## Usage in the archive

Used by 25 rules.

Format 6 replacement, from `paizo-pathfinder-player-core-2/class/alchemist/alchemy-benefits/formula-book.yml`:

```yaml
- key: learn-choice-alchemist-formulas-starting
  forEach: $.alchemist.formulas.starting
  effect: core/add-to-list
  inputs:
    list: $.crafting.formulas
    value: {item: true}
```
