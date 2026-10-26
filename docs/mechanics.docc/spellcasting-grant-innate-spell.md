# spellcasting/grant-innate-spell

Creates a dedicated innate spellcasting source and grants a specific innate spell to it.

Effect `grant-innate-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `sourceName` | `string` | yes |
| `grantId` | `uuid` | yes |
| `spellId` | `spell-id` | yes |
| `tradition` | `tradition` | yes |
| `attribute` | `attribute` | yes |
| `rankPolicy` | `rank-policy` | yes |
| `castFrequency` | `cast-frequency` | yes |

Derived from the rule key, never written: `grantId`.

## Usage in the archive

Used by 11 rules.

Example, from `paizo-pathfinder-player-core/feat/first-world-magic.yml`:

```yaml
- key: grant-innate-spell-1
  effect: spellcasting/grant-innate-spell
  inputs:
    sourceId: f9fc550d-e6c9-5b90-9142-c5607ad4e3fd
    sourceName: First World Magic
    spellId: {choice: $.feat.first-world-magic.cantrip}
    tradition: primal
    attribute: cha
    rankPolicy: {kind: cantrip}
    castFrequency: {kind: atWill}
```
