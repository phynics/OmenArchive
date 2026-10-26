# core/add-skill-increase

Increases the character's proficiency rank in a standard skill up to the specified proficiency cap.

Effect `add-skill-increase`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `skill` | `skill` | yes |
| `proficiencyCap` | `proficiency-rank` | yes |

## Writes

- domain `skill`, name input `skill`

## Usage in the archive

Used by 121 rules.

Example, from `paizo-pathfinder-player-core/archetype/wizard/feats/wizard-dedication.yml`:

```yaml
- key: add-skill-increase-1
  effect: core/add-skill-increase
  inputs:
    skill: {kind: arcana}
    proficiencyCap: 2
```
