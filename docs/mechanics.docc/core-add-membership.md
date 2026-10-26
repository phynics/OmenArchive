# core/add-membership

Registers the character in a named organization, class order, or school (e.g. druid order, bard muse).

Effect `add-membership`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `list` | `string` | yes |
| `value` | `feature-id` | yes |

## Writes

- domain `path`, name input `list`

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/muses.yml`:

```yaml
- key: choice-set-2
  effect: core/add-membership
  inputs:
    list: \$.bard.muse-memberships
    value: {choice: $.bard.muse}
```
