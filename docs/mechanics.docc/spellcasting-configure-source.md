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

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Writes

- domain `spellcasting`, name `spellcasting`

## Usage in the archive

Used by 147 rules.

Example, from `paizo-pathfinder-player-core-2/archetype/blessed-one/feats/blessed-one-dedication.yml`:

```yaml
- effect: spellcasting/configure-source
  inputs:
    attribute: charisma
    castingKind: focus
    source: blessed-one-focus-spells
    sourceName: Blessed One Focus Spells
    tradition: divine
  key: blessed-one-focus-source
```
