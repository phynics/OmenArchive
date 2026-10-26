# core/extend-class-key-attribute

Adds an attribute to the list of choices for the character's key class attribute.

Effect `extend-class-key-attribute`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `attribute` | `attribute` | yes |

## Usage in the archive

Used by 3 rules.

Example, from `paizo-pathfinder-player-core/class/rogue/rackets/mastermind.yml`:

```yaml
- key: key-attribute
  effect: core/extend-class-key-attribute
  inputs:
    attribute: int
```
