# core/add-hit-points@2

Adds to the character's maximum Hit Points: a number, or an expression that grows with the character (Toughness's $.level; Fighter Resiliency's 3 for each Fighter archetype feat).

Effect `add-hit-points`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `amount` | `sheet-value` | yes |

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/archetype/fighter/feats/fighter-resiliency.yml`:

```yaml
- effect: core/add-hit-points@2
  inputs:
    amount: (multiply 3 $.archetype.fighter.feat-count)
  key: hit-points-per-feat
```
