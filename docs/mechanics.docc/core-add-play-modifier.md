# core/add-play-modifier

Adds a typed bonus or penalty to the rolls it targets at the table, optionally only in a situation the player toggles or while a condition on the character holds.

Effect `add-play-modifier`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `string` | yes |
| `slug` | `string` | yes |
| `target` | `roll-description` | yes |
| `amount` | `int` | yes |
| `bonusType` | `string` | yes |
| `mode` | `string` | yes |
| `condition` | `string` | yes |
| `requires` | `sheet-value` | no |

## Writes

- domain `roll-modifier`, name `play-annotation`

## Usage in the archive

Used by 65 rules.

Example, from `paizo-pathfinder-player-core-2/archetype/herbalist/feats/fresh-ingredients.yml`:

```yaml
- effect: core/add-play-modifier
  inputs:
    amount: 4
    bonusType: circumstance
    condition: Treat Wounds; natural medicine; terrain wilderness
    mode: add
    slug: fresh-herbs-wild
    source: Fresh Ingredients
    target:
      description:
      - skill:
          _0:
            nature: {}
  key: annotation-1
```
