# core/add-defense

Grants a weakness (with its amount, which may grow with the character) or an immunity to a damage type or an effect, or makes the character healed by an energy other than vitality (void, as an undead creature is) and harmed by the other, optionally only in a situation (when).

Effect `add-defense`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `defense` | `string` | yes |
| `type` | `string` | yes |
| `value` | `sheet-value` | no |
| `when` | `string` | no |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core-2/versatile-heritage/dhampir.yml`:

```yaml
- effect: core/add-defense
  inputs:
    defense: healing
    type: void
  key: void-healing
```
