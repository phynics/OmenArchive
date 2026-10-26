# core/add-heritage-by-id

Applies the rules and features of a second heritage without altering the character's primary heritage identity (e.g. Elf Atavism).

Effect `add-heritage-by-id`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `heritageId` | `heritage-id` | yes |

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/elf-atavism.yml`:

```yaml
- key: grant-heritage
  effect: core/add-heritage-by-id
  inputs:
    heritageId: {choice: $.feat.elf-atavism.heritage}
```
