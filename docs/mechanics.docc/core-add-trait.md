# core/add-trait

Grants a trait to the character (e.g. undead, construct, amphibious). With as: ancestry it is an ancestry trait: it counts for hasTrait and opens that ancestry's feats.

Effect `add-trait`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `trait` | `string` | yes |
| `as` | `string` | no |

## Writes

- domain `trait`, name input `trait`

## Usage in the archive

Used by 11 rules.

Example, from `paizo-pathfinder-player-core-2/versatile-heritage/dhampir.yml`:

```yaml
- effect: core/add-trait
  inputs:
    as: ancestry
    trait: dhampir
  key: grant-heritage-trait
```
