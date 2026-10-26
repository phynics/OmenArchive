# spellcasting/grant-focus-spell

Grants a focus spell to a spellcasting source and establishes its focus cantrip or focus spell scaling.

Effect `grant-focus-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `spellId` | `spell-id` | yes |

## Usage in the archive

Used by 8 rules.

Example, from `paizo-pathfinder-player-core/feat/masterful-warden.yml`:

```yaml
- key: grant-warden-spell
  effect: spellcasting/grant-focus-spell
  inputs:
    sourceId: ad075a6c-56ec-5561-ae46-5a8565022188
    spellId: {choice: $.feat.masterful-warden.spell}
```
