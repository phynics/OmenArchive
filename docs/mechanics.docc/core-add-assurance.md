# core/add-assurance

Grants the Assurance feat benefit for a skill, allowing fixed roll results ignoring penalties.

Effect `add-assurance`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `skill` | `skill` | yes |

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/feat/assurance.yml`:

```yaml
- key: add-assurance-1
  effect: core/add-assurance
  inputs:
    skill: {choice: $.feat.assurance.skills}
```
