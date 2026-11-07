# core/add-to-list

Adds a value to a character list. A list is a set: the same value from two sources is one item with two origins.

Effect `add-to-list`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `list` | `list-path` | yes |
| `value` | `list-item` | yes |

## Writes

- domain `path`, name input `list`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/adopted-ancestry.yml`:

```yaml
- effect: core/add-to-list
  inputs:
    list: $.ancestry.feat-ancestries
    value:
      choice: $.feats.adopted-ancestry.ancestry
  key: feat-ancestry
```
