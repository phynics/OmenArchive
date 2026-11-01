# core/add-heritage-by-id@2

Applies the rules and features of a second heritage without altering the character's primary heritage identity (e.g. Elf Atavism).

Effect `add-heritage-by-id`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `heritage` | `heritage-id` | yes |

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/elf-atavism.yml`:

```yaml
- effect: core/add-heritage-by-id@2
  inputs:
    heritage:
      choice: $.feat.elf-atavism.heritage
  key: grant-heritage
```
