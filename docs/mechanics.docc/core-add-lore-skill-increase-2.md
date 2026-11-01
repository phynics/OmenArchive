# core/add-lore-skill-increase@2

Increases the character's proficiency rank in a specific Lore sub-skill up to the specified cap, creating the Lore skill if not already present.

Effect `add-lore-skill-increase`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `loreName` | `string` | yes |
| `rank` | `proficiency-rank` | yes |

## Writes

- domain `skill`, name input `loreName`

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/feat/additional-lore.yml`:

```yaml
- effect: core/add-lore-skill-increase@2
  inputs:
    loreName:
      choice: $.feat.additional-lore.lores
    rank: trained
  key: add-lore-skill-increase-1
```
