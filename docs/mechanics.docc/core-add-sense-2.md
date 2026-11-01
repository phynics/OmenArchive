# core/add-sense@2

Grants a special sense (such as darkvision, scent, or tremorsense), with the acuity and range when it has them.

Effect `add-sense`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sense` | `string` | yes |
| `acuity` | `string` | no |
| `range` | `int` | no |

## Writes

- domain `sense`, name input `sense`

## Usage in the archive

Used by 19 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/catfolk/heritages/hunting-catfolk.yml`:

```yaml
- effect: core/add-sense@2
  inputs:
    acuity: imprecise
    range: 30
    sense: scent
  key: sense-1
```
