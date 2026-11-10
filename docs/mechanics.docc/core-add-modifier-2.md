# core/add-modifier@2

Adds a typed bonus or penalty to the rolls it targets, optionally only in a situation the player toggles (when) or while a condition on the character holds (requires). The amount is a number or an expression worked out from the character.

Revision 2: `amount` is a number or an expression. A bonus that depends on the character, such as +1 and +2 for a master, is `(add 1 (gte $.skills.crafting.rank master))`.

Effect `add-modifier`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `target` | `roll-description` | yes |
| `amount` | `sheet-value` | yes |
| `type` | `string` | yes |
| `when` | `string` | no |
| `requires` | `sheet-value` | no |

## Writes

- domain `roll-modifier`, name `play-annotation`

## Usage in the archive

Used by 0 rules.
