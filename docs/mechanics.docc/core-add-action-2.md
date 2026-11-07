# core/add-action@2

Grants an action to the character by its canonical identifier, making it available on the character sheet.

Effect `add-action`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `action` | `action-id` | yes |

## Usage in the archive

Used by 27 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/hobgoblin/heritages/elfbane-hobgoblin.yml`:

```yaml
- effect: core/add-action@2
  inputs:
    action: '@action.resist-elf-magic'
  key: resist-elf-magic-action
```
