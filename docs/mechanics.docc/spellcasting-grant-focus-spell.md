# spellcasting/grant-focus-spell

Grants a focus spell to a spellcasting source and establishes its focus cantrip or focus spell scaling.

Effect `grant-focus-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spellId` | `spell-id` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 8 rules.

Example, from `paizo-pathfinder-player-core/feat/masterful-warden.yml`:

```yaml
- key: grant-warden-spell
  effect: spellcasting/grant-focus-spell
  inputs:
    source: ranger-focus-spells
    spellId: {choice: $.feat.masterful-warden.spell}
```
