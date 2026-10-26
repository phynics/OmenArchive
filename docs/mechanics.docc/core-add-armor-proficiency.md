# core/add-armor-proficiency

Grants training or another proficiency rank in an armor category or specific armor. When selfScaling is true, the rank automatically increases when the character's unarmored defense scales.

Effect `add-armor-proficiency`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `armorDesignation` | `armor-designation` | yes |
| `proficiencyRank` | `proficiency-rank` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `armor-proficiency`, name `armor`

## Usage in the archive

Used by 67 rules.

Example, from `paizo-pathfinder-player-core/class/fighter/features/armor-mastery.yml`:

```yaml
- key: generated-2
  effect: core/add-armor-proficiency
  inputs:
    armorDesignation: {armorKind: light, kind: type}
    proficiencyRank: 6
    selfScaling: false
```
