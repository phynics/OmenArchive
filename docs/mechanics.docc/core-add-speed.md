# core/add-speed

Sets the character's Speed in a movement type (land, climb, swim, fly or burrow), or adds a bonus or penalty in feet to it.

Effect `add-speed`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `movement` | `string` | yes |
| `speed` | `int` | no |
| `bonus` | `int` | no |

## Writes

- domain `speed`, name `speed`

## Usage in the archive

Used by 13 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/kholo/heritages/dog-kholo.yml`:

```yaml
- effect: core/add-speed
  inputs:
    movement: land
    speed: 30
  key: land-speed
```
