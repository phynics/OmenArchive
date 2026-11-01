# core/add-membership@2

Registers the character in a named organization, class order, or school (e.g. druid order, bard muse).

Effect `add-membership`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `list` | `list-path` | yes |
| `value` | `feature-id` | yes |

## Writes

- domain `path`, name input `list`

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/muses.yml`:

```yaml
- effect: core/add-membership@2
  inputs:
    list: $.bard.muse-memberships
    value:
      choice: $.bard.muse
  key: choice-set-2
```
