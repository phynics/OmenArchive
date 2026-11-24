# core/add-speed@2

Sets the character's Speed in a movement type (land, climb, swim, fly or burrow), or adds a bonus or penalty in feet to land Speed. A Speed other than land may be worked out from the land Speed ($.speed.land) or hold only in a situation (when).

Effect `add-speed`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `movement` | `string` | yes |
| `speed` | `sheet-value` | no |
| `bonus` | `int` | no |
| `when` | `string` | no |

## Writes

- domain `speed`, name `speed`

## Usage in the archive

Used by 34 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/kholo/heritages/dog-kholo.yml`:

```yaml
- effect: core/add-speed@2
  inputs:
    movement: land
    speed: 30
  key: land-speed
```
