# core/add-feat-ancestry

Grants access to select ancestry feats from an additional ancestry without acquiring its physical traits (e.g. Adopted Ancestry).

Effect `add-feat-ancestry`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `ancestry` | `string` | yes |

## Writes

- domain `path`, name `$.ancestry.feat-ancestries`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/adopted-ancestry.yml`:

```yaml
- key: feat-ancestry
  effect: core/add-feat-ancestry
  inputs:
    ancestry: {choice: $.feat.adopted-ancestry.ancestry}
```
