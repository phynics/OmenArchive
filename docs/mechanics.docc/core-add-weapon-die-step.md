# core/add-weapon-die-step

Increases the damage die of the deity's favored weapon by one step (e.g. 1d4 to 1d6) if it is a simple weapon or 1d4 unarmed attack.

Effect `add-weapon-die-step`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `weapon` | `weapon-reference` | yes |

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core-2/class/champion/deity-benefits/deific-weapon.yml`:

```yaml
- key: deity-favored-weapon-die
  effect: core/add-weapon-die-step
  inputs:
    weapon: {choice: $.deity.favored-weapon}
```
