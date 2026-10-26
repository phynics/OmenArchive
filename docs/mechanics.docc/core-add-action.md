# core/add-action

Grants an action to the character by its canonical identifier, making it available on the character sheet.

Effect `add-action`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `actionId` | `action-id` | yes |

## Usage in the archive

Used by 27 rules.

Example, from `paizo-pathfinder-player-core/archetype/fighter/feats/reactive-striker.yml`:

```yaml
- key: add-action-1
  effect: core/add-action
  inputs:
    actionId: '@action.reactive-strike'
```
