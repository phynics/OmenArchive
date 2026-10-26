# core/set-ancestry-hit-points

Sets the base Hit Points provided by the character's ancestry.

Effect `set-ancestry-hit-points`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `hitPoints` | `int` | yes |

## Usage in the archive

Used by 6 rules.

Example, from `paizo-pathfinder-player-core/ancestry/goblin/heritages/unbreakable-goblin.yml`:

```yaml
- key: set-ancestry-hit-points-1
  effect: core/set-ancestry-hit-points
  inputs:
    hitPoints: 10
```
