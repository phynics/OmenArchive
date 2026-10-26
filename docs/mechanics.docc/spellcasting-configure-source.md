# spellcasting/configure-source

Establishes a new spellcasting source with defined casting type, tradition, and key attribute.

Effect `configure-source`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `sourceName` | `string` | yes |
| `castingKind` | `casting-kind` | yes |
| `tradition` | `tradition` | yes |
| `attribute` | `attribute` | yes |

## Writes

- domain `spellcasting`, name `spellcasting`

## Usage in the archive

Used by 146 rules.

Example, from `paizo-pathfinder-player-core/feat/advanced-domain.yml`:

```yaml
- key: configure-source-1
  effect: spellcasting/configure-source
  inputs:
    sourceId: b7e73ea3-1be8-5215-a0c7-055d23080c56
    sourceName: Cleric Focus Spells
    castingKind: focus
    tradition: divine
    attribute: wis
```
