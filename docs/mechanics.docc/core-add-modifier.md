# core/add-modifier

Adds a typed bonus or penalty to the rolls it targets, optionally only in a situation the player toggles (when) or while a condition on the character holds (requires).

> **Removed in format 6.** A format 6 reader refuses this revision. Write `core/add-modifier@2` instead; `amount` is a number or an expression there.

Effect `add-modifier`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `target` | `roll-description` | yes |
| `amount` | `int` | yes |
| `type` | `string` | yes |
| `when` | `string` | no |
| `requires` | `sheet-value` | no |

## Writes

- domain `roll-modifier`, name `play-annotation`

## Usage in the archive

Used by 134 rules.

Format 6 replacement, based on `paizo-pathfinder-player-core-2/ancestry/catfolk/heritages/hunting-catfolk.yml`:

```yaml
- effect: core/add-modifier@2
  inputs:
    amount: 2
    target: survival
    type: circumstance
    when: Track
  key: flat-modifier-1
```
