# core/add-feat@2

Grants a specific feat to the character under a unique selection identity, optionally passing nested choice settings for choices within the granted feat.

Effect `add-feat`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `selectionId` | `uuid` | yes |
| `featId` | `feat-id` | yes |
| `with` | `feat-choice-settings` | no |

Derived from the rule key, never written: `selectionId`.

## Usage in the archive

Used by 98 rules.

Example, from `paizo-pathfinder-player-core/background/nomad.yml`:

```yaml
- key: add-feat-1
  effect: core/add-feat@2
  inputs:
    featId: '@feat.assurance'
    with:
      $.feat.assurance.skills:
        kind: fixed
        value:
          payload:
            kind: survival
          revision: 1
          typeID: me.atkn.omen.pf2e.playercore/value/skill
```
