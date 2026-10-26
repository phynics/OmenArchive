# core/add-feature-by-id

Grants a class, ancestry, or general feature to the character by its canonical identifier.

Effect `add-feature-by-id`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `featureId` | `feature-id` | yes |

## Usage in the archive

Used by 57 rules.

Example, from `paizo-pathfinder-player-core/feat/major-lesson.yml`:

```yaml
- key: choice-set-1
  effect: core/add-feature-by-id
  inputs:
    featureId: {choice: $.feat.major-lesson.lessons}
```
