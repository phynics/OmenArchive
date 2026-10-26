# core/add-character-ancestry-trait

Adds an ancestry trait to the character, unlocking access to feats requiring that ancestry.

Effect `add-character-ancestry-trait`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `trait` | `string` | yes |

## Writes

- domain `trait`, name input `trait`

## Usage in the archive

Used by 9 rules.

Example, from `paizo-pathfinder-player-core/versatile-heritage/dromaar.yml`:

```yaml
- key: add-character-ancestry-trait-1
  effect: core/add-character-ancestry-trait
  inputs:
    trait: dromaar
```
