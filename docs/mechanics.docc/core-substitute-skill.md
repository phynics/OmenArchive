# core/substitute-skill

Allows one skill to substitute for another: the substitute skill's rank satisfies prerequisites and can replace the primary skill on checks, without altering base proficiency values.

Effect `substitute-skill`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `skill` | `skill` | yes |
| `substitute` | `skill` | yes |

## Writes

- domain `skill`, name input `skill`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/research-fields/chirurgeon.yml`:

```yaml
- key: chirurgeon-crafting-for-medicine
  effect: core/substitute-skill
  inputs:
    skill: {kind: medicine}
    substitute: {kind: crafting}
```
