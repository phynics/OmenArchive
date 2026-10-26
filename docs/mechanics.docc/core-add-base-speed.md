# core/add-base-speed

Sets or unlocks an alternate movement speed such as swim, climb, fly, or burrow.

Effect `add-base-speed`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `selector` | `string` | yes |
| `value` | `int` | yes |

## Writes

- domain `speed`, name `speed`

## Usage in the archive

Used by 8 rules.

Example, from `paizo-pathfinder-player-core/feat/cave-climber.yml`:

```yaml
- key: add-base-speed-1
  effect: core/add-base-speed
  inputs:
    selector: climb
    value: 10
```
