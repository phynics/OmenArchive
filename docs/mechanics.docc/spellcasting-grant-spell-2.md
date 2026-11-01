# spellcasting/grant-spell@2

Grants a specific spell to a spellcasting source with specified rank policy and casting frequency.

Effect `grant-spell`, revision 2, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `grantId` | `uuid` | yes |
| `spell` | `spell-id` | yes |
| `rankPolicy` | `rank-policy` | yes |
| `castFrequency` | `cast-frequency` | yes |

Derived from the rule key, never written: `grantId`.

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 11 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/composition-spells.yml`:

```yaml
- effect: spellcasting/grant-spell@2
  inputs:
    castFrequency: atWill
    rankPolicy: cantrip
    source: bard-focus-spells
    spell: '@spell.courageous-anthem'
  key: grant-spell-1
```
