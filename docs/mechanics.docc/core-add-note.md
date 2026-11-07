# core/add-note

Adds a note to the rolls it targets, optionally only in a situation the player toggles (when) or while a condition on the character holds (requires). A change to the degree of success is a note.

Effect `add-note`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `target` | `roll-description` | yes |
| `text` | `string` | yes |
| `when` | `string` | no |
| `requires` | `sheet-value` | no |

## Writes

- domain `roll-modifier`, name `play-annotation`

## Usage in the archive

Used by 80 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/chemical-hardiness.yml`:

```yaml
- effect: core/add-note
  inputs:
    target: fortitude
    text: When you roll a success on a Fortitude save, the result is one degree better.
  key: fortitude-success-note
  level: 11
```
