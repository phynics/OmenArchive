# spellcasting/configure-source

Establishes a new spellcasting source with defined casting type, tradition, and key attribute.

Effect `configure-source`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `sourceName` | `string` | yes |
| `castingKind` | `casting-kind` | yes |
| `tradition` | `tradition` | yes |
| `attribute` | `attribute` | yes |

## Writes

- domain `spellcasting`, name `spellcasting`

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 146 rules.

Example, from `paizo-pathfinder-player-core/feat/advanced-domain.yml`:

```yaml
- key: configure-source-1
  effect: spellcasting/configure-source
  inputs:
    source: cleric-focus-spells
    sourceName: Cleric Focus Spells
    castingKind: focus
    tradition: divine
    attribute: wisdom
```
