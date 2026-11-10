# core/add-terrain-expertise

Grants a +1 circumstance bonus to Survival checks within a specific terrain type.

> **Removed in format 6.** A format 6 reader refuses this effect. Write a rule with `forEach` over the list the question adds to, giving an `add-modifier@2` for each terrain, instead.

Effect `add-terrain-expertise`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `terrain` | `terrain` | yes |

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 1 rules.

Format 6 replacement, from `paizo-pathfinder-player-core/feat/terrain-expertise.yml`:

```yaml
- key: terrain-bonus
  forEach: $.feats.terrain-expertise.terrains
  effect: core/add-modifier@2
  inputs:
    target: survival
    amount: 1
    type: circumstance
    when: in {item} terrain
```
