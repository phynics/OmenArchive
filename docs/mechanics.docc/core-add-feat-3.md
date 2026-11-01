# core/add-feat@3

Grants a specific feat to the character under a unique selection identity, optionally passing nested choice settings for choices within the granted feat.

Effect `add-feat`, revision 3, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `selectionId` | `uuid` | yes |
| `feat` | `feat-id` | yes |
| `with` | `feat-choice-settings` | no |

Derived from the rule key, never written: `selectionId`.

## Usage in the archive

Used by 98 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/catfolk/heritages/nine-lives-catfolk.yml`:

```yaml
- effect: core/add-feat@3
  inputs:
    feat: '@feat.diehard?source=paizo-pathfinder-player-core'
  key: grant-item-1
```
