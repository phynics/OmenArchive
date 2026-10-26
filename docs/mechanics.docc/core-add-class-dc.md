# core/add-class-dc

Raises the character's class DC proficiency rank. When className is provided, establishes a separate class DC using the specified key attribute.

Effect `add-class-dc`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `proficiencyRank` | `proficiency-rank` | yes |
| `className` | `string` | no |
| `keyAttribute` | `attribute` | no |

## Writes

- domain `class-dc`, name `class-dc`

## Usage in the archive

Used by 27 rules.

Example, from `paizo-pathfinder-player-core/archetype/fighter/feats/fighter-dedication.yml`:

```yaml
- key: dedication-class-dc
  effect: core/add-class-dc
  inputs:
    proficiencyRank: 2
    className: fighter
    keyAttribute: {choice: $.fighter.class-dc-attribute}
```
