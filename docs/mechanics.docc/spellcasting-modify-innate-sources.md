# spellcasting/modify-innate-sources

Alters the effective tradition of innate spell sources granted by matching features or heritages.

Effect `modify-innate-sources`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `grantedBy` | `resource-filter` | yes |
| `tradition` | `tradition` | yes |
| `setTradition` | `tradition` | yes |

## Writes

- domain `innate-tradition`, name `tradition`

## Usage in the archive

Used by 1 rules.

Example, from `paizo-pathfinder-player-core/ancestry/gnome/heritages/wellspring-gnome.yml`:

```yaml
- effect: spellcasting/modify-innate-sources
  inputs:
    grantedBy:
      all:
      - type: feat
      - trait: systemTrait-ancestry
      - trait: ancestryTrait-gnome
    setTradition:
      choice: $.gnome.wellspring-tradition
    tradition: primal
  key: modify-innate-sources
```
