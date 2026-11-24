# core/add-resistance@3

Grants damage resistance against a damage type, which may scale with character level or have exceptions, optionally only in a situation (when).

Effect `add-resistance`, revision 3, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `type` | `string` | yes |
| `value` | `sheet-value` | yes |
| `exceptions` | `string` | no, default `""` |
| `when` | `string` | no |

## Usage in the archive

Used by 33 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/catfolk/heritages/winter-catfolk.yml`:

```yaml
- effect: core/add-resistance@3
  inputs:
    type: cold
    value: (max 1 (divide $.level 2))
  key: cold-resistance
```
