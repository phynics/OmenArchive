# core/add-class-dc@2

Raises the character's class DC proficiency rank. When className is provided, establishes a separate class DC using the specified key attribute.

Effect `add-class-dc`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `rank` | `proficiency-rank` | yes |
| `className` | `string` | no |
| `keyAttribute` | `attribute` | no |

## Writes

- domain `class-dc`, name `class-dc`

## Usage in the archive

Used by 27 rules.

Example, from `paizo-pathfinder-player-core-2/archetype/alchemist/feats/alchemist-dedication.yml`:

```yaml
- effect: core/add-class-dc@2
  inputs:
    className: alchemist
    keyAttribute: intelligence
    rank: trained
  key: dedication-class-dc
```
