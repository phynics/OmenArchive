# core/add-specialty-crafting

Grants a +1 circumstance bonus to Crafting checks for items in the chosen specialty (+2 if master in Crafting).

> **Removed in format 6.** A format 6 reader refuses this effect. Write an `add-modifier@2` rule instead: +1, and +2 for a master in Crafting, to crafting items of the chosen specialty.

Effect `add-specialty-crafting`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `specialty` | `crafting-specialty` | yes |

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 1 rules.

Format 6 replacement, from `paizo-pathfinder-player-core/feat/specialty-crafting.yml`:

```yaml
- key: specialty-crafting-bonus
  effect: core/add-modifier@2
  inputs:
    target: crafting
    amount: (add 1 (gte $.skills.crafting.rank master))
    type: circumstance
    when: to Craft {$.feats.specialty-crafting.specialty} items
```
