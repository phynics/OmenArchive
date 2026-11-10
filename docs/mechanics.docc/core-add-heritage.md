# core/add-heritage

Applies the rules and features of a second heritage without altering the character's primary heritage identity (e.g. Elf Atavism).

> **Removed in format 6.** A format 6 reader refuses this effect. Write `core/add-feature@2`, which takes a heritage, instead.

Effect `add-heritage`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `heritage` | `heritage-id` | yes |

## Usage in the archive

Used by 1 rules.

Format 6 replacement, from `paizo-pathfinder-player-core/feat/elf-atavism.yml`:

```yaml
- key: grant-heritage
  effect: core/add-feature@2
  inputs:
    feature: {choice: $.feats.elf-atavism.heritage}
```
