# core/declare-list

Declares a character list: a named, typed set of items that other rules add to and read (e.g. the skills a character has Assurance in). Declaring the same list again with the same type changes nothing.

Effect `declare-list`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `list` | `list-path` | yes |
| `valueType` | `list-value-type` | yes |
| `label` | `string` | no |

## Usage in the archive

Used by 6 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/muses.yml`:

```yaml
- effect: core/declare-list
  inputs:
    label: Bard muses
    list: $.bard.muses
    valueType:
      records: '@class.bard.muses'
  key: muse-list
```
