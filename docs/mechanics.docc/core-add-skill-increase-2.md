# core/add-skill-increase@2

Increases the character's proficiency rank in a standard skill, up to the specified rank.

Effect `add-skill-increase`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `skill` | `skill` | yes |
| `rank` | `proficiency-rank` | yes |

## Writes

- domain `skill`, name input `skill`

## Usage in the archive

Used by 128 rules.

Example, from `paizo-pathfinder-player-core-2/ancestry/kholo/heritages/ant-kholo.yml`:

```yaml
- effect: core/add-skill-increase@2
  inputs:
    rank: trained
    skill: deception
  key: deception-trained
```
