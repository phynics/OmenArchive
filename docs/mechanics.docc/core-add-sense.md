# core/add-sense

Grants a special sense (such as darkvision, scent, or tremorsense) with specified acuity and range.

Effect `add-sense`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `selector` | `string` | yes |
| `acuity` | `string` | yes |
| `range` | `int` | yes |

## Writes

- domain `sense`, name input `selector`

## Usage in the archive

Used by 19 rules.

Example, from `paizo-pathfinder-player-core/ancestry/gnome/heritages/sensate-gnome.yml`:

```yaml
- key: add-sense-1
  effect: core/add-sense
  inputs:
    selector: scent
    acuity: imprecise
    range: 30
```
