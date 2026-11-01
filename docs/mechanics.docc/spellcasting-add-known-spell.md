# spellcasting/add-known-spell

Adds spells to a spontaneous caster's spell repertoire or a prepared caster's spellbook.

Effect `add-known-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spells` | `spell-id-list` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

`spells` is a list: one spell is a list of one (`[spell/soothe]`), and a single answered choice is read with `{choiceList: $.deity.spells.rank-1}`. To let the player pick spells instead, use `allow-known-spells`. Each spell gets its own repertoire entry, with an identity derived from the rule and the spell, so replaying the rule adds nothing twice. The effect adds to the repertoire or spellbook only; to also widen the source's spell list, add an `add-spell-list` rule with the same spells.

## Usage in the archive

Used by 240 rules.

Example, from `paizo-pathfinder-player-core/class/bard/muses/polymath.yml`:

```yaml
- key: add-known-spell-1
  effect: spellcasting/add-known-spell
  inputs:
    source: bard-spellcasting
    spells: ['@spell.phantasmal-minion']
```
