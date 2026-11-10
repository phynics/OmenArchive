# core/substitute-skill

Allows one skill to substitute for another: the substitute skill's rank satisfies prerequisites and can replace the primary skill on checks, without altering base proficiency values.

> **Removed in format 6.** A format 6 reader refuses this effect. Write an `add-to-list` rule on `$.skills.substitutions` with an entry of `skill` and `substitute`, and an `add-note` rule beside it, instead.

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

Format 6 replacement, from `paizo-pathfinder-player-core-2/class/alchemist/research-fields/chirurgeon.yml`:

```yaml
- key: chirurgeon-crafting-for-medicine
  effect: core/add-to-list
  inputs:
    list: $.skills.substitutions
    value:
      entry:
        skill: {type: core/skill, value: medicine}
        substitute: {type: core/skill, value: crafting}
- key: chirurgeon-crafting-for-medicine-note
  effect: core/add-note
  inputs:
    target: medicine
    text: 'Crafting can replace Medicine: its rank meets Medicine prerequisites and
      it stands in for Medicine checks.'
```
