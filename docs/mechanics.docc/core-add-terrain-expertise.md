# core/add-terrain-expertise

Grants a +1 circumstance bonus to Survival checks within a specific terrain type.

Effect `add-terrain-expertise`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `terrain` | `terrain` | yes |

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/terrain-expertise.yml`:

```yaml
- key: add-terrain-expertise-1
  effect: core/add-terrain-expertise
  inputs:
    terrain: {choice: $.feat.terrain-expertise.terrains}
```
