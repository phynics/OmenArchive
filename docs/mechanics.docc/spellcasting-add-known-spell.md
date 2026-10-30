# spellcasting/add-known-spell

Adds a spell to a spontaneous caster's spell repertoire or a prepared caster's spellbook.

Effect `add-known-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `entryId` | `uuid` | yes |
| `spellId` | `spell-id` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 231 rules.

Example, from `paizo-pathfinder-player-core/class/bard/muses/polymath.yml`:

```yaml
- key: add-known-spell-1
  effect: spellcasting/add-known-spell
  inputs:
    source: bard-spellcasting
    entryId: 391accd6-b16f-5405-9256-7fc80fef11b9
    spellId: '@spell.phantasmal-minion'
```
