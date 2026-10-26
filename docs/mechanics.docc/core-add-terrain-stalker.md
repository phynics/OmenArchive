# core/add-terrain-stalker

Enables the character to Sneak across a specific terrain type without cover or concealment.

Effect `add-terrain-stalker`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `terrain` | `string` | yes |

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/terrain-stalker.yml`:

```yaml
- key: add-terrain-stalker-1
  effect: core/add-terrain-stalker
  inputs:
    terrain: {choice: $.feat.terrain-stalker.terrains}
```
