# spellcasting/grant-spell

Grants a specific spell to a spellcasting source with specified rank policy and casting frequency.

Effect `grant-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `grantId` | `uuid` | yes |
| `spellId` | `spell-id` | yes |
| `rankPolicy` | `rank-policy` | yes |
| `castFrequency` | `cast-frequency` | yes |

Derived from the rule key, never written: `grantId`.

## Usage in the archive

Used by 120 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/composition-spells.yml`:

```yaml
- key: grant-spell-1
  effect: spellcasting/grant-spell
  inputs:
    sourceId: 82cec964-0fa9-5155-b45a-790771953c07
    spellId: '@spell.counter-performance'
    rankPolicy: {kind: cantrip}
    castFrequency: {kind: focus}
```
