# spellcasting/grant-innate-spell@2

Creates a dedicated innate spellcasting source and grants a specific innate spell to it.

Effect `grant-innate-spell`, revision 2, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `sourceName` | `string` | yes |
| `grantId` | `uuid` | yes |
| `spell` | `spell-id` | yes |
| `tradition` | `tradition` | yes |
| `attribute` | `attribute` | yes |
| `rankPolicy` | `rank-policy` | yes |
| `castFrequency` | `cast-frequency` | yes |

Derived from the rule key, never written: `grantId`.

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 11 rules.

Example, from `paizo-pathfinder-player-core/ancestry/gnome/heritages/wellspring-gnome.yml`:

```yaml
- effect: spellcasting/grant-innate-spell@2
  inputs:
    attribute: charisma
    castFrequency: atWill
    rankPolicy: cantrip
    source: wellspring-gnome
    sourceName: Wellspring Gnome
    spell:
      choice: $.gnome.wellspring-cantrip
    tradition:
      choice: $.gnome.wellspring-tradition
  key: grant-wellspring-cantrip
```
