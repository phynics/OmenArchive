# core/add-play-note

Adds a note to the rolls it targets at the table, optionally only in a situation or while a condition on the character holds. A change to the degree of success is a note.

Effect `add-play-note`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `string` | yes |
| `slug` | `string` | yes |
| `target` | `roll-description` | yes |
| `text` | `string` | yes |
| `condition` | `string` | yes |
| `requires` | `sheet-value` | no |

## Writes

- domain `roll-modifier`, name `play-annotation`

## Usage in the archive

Used by 63 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/chemical-hardiness.yml`:

```yaml
- effect: core/add-play-note
  inputs:
    condition: ''
    slug: degree
    source: Chemical Hardiness
    target:
      description:
      - savingThrow:
          _0: fortitude
    text: When you roll a success on a Fortitude save, the result is one degree better.
  key: annotation-1
  level: 11
```
