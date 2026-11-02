# core/add-heritage

Applies the rules and features of a second heritage without altering the character's primary heritage identity (e.g. Elf Atavism).

Effect `add-heritage`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `heritage` | `heritage-id` | yes |

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/elf-atavism.yml`:

```yaml
- effect: core/add-heritage
  inputs:
    heritage:
      choice: $.feats.elf-atavism.heritage
  key: grant-heritage
```
