# core/add-hit-points-per-count

Grants additional Hit Points scaling with the count of feats taken from a specific archetype.

Effect `add-hit-points-per-count`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `amount` | `int` | yes |
| `count` | `string` | yes |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core/archetype/fighter/feats/fighter-resiliency.yml`:

```yaml
- key: add-hit-points-per-count-1
  effect: core/add-hit-points-per-count
  inputs:
    amount: 3
    count: \$.archetype.fighter.feat-count
```
