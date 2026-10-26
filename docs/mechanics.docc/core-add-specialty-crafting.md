# core/add-specialty-crafting

Grants a +1 circumstance bonus to Crafting checks for items in the chosen specialty (+2 if master in Crafting).

Effect `add-specialty-crafting`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `specialty` | `crafting-specialty` | yes |

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/specialty-crafting.yml`:

```yaml
- key: add-specialty-crafting-1
  effect: core/add-specialty-crafting
  inputs:
    specialty: {choice: $.feat.specialty-crafting.specialty}
```
