# core/add-lore-skill-increase

Increases the character's proficiency rank in a specific Lore sub-skill up to the specified cap, creating the Lore skill if not already present.

Effect `add-lore-skill-increase`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `loreName` | `string` | yes |
| `proficiencyCap` | `proficiency-rank` | yes |

## Writes

- domain `skill`, name input `loreName`

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/feat/additional-lore.yml`:

```yaml
- key: add-lore-skill-increase-1
  effect: core/add-lore-skill-increase
  inputs:
    loreName: {choice: $.feat.additional-lore.lores}
    proficiencyCap: 2
```
