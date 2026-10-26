# core/add-resistance@2

Grants damage resistance against a damage type, which may scale with character level or have exceptions.

Effect `add-resistance`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `type` | `string` | yes |
| `value` | `sheet-value` | yes |
| `exceptions` | `string` | yes |

## Usage in the archive

Used by 15 rules.

Example, from `paizo-pathfinder-player-core/feat/nephilim-resistance.yml`:

```yaml
- key: add-resistance-1
  effect: core/add-resistance@2
  inputs:
    type: {choice: $.feat.nephilim-resistance.damage-type}
    value: 5
    exceptions: ''
```
