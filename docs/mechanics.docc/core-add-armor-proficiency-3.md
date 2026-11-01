# core/add-armor-proficiency@3

Grants training or another proficiency rank in armor: a category, a category the player chose, or one armor. When selfScaling is true, the rank automatically increases when the character's unarmored defense scales.

Effect `add-armor-proficiency`, revision 3, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `armor` | `list-item` | yes |
| `rank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `armor-proficiency`, name `armor`

## Usage in the archive

Used by 67 rules.

Example, from `paizo-pathfinder-player-core-2/class/alchemist/features/medium-armor-expertise.yml`:

```yaml
- effect: core/add-armor-proficiency@3
  inputs:
    armor:
      category: light
    rank: expert
  key: generated-3
  level: 13
```
