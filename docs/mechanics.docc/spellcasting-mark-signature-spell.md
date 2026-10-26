# spellcasting/mark-signature-spell

Designates a known spell in a spontaneous caster's repertoire as a signature spell, allowing heightening without separate learning.

Effect `mark-signature-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `spellId` | `spell-id` | yes |

## Writes

- domain `signature-spell`, name input `spellId`

## Usage in the archive

Used by 30 rules.

Example, from `paizo-pathfinder-player-core/class/bard/features/signature-spells.yml`:

```yaml
- key: mark-signature-spell-1
  effect: spellcasting/mark-signature-spell
  level: 3
  inputs:
    sourceId: '@class.bard.features.bard-spellcasting#spellcasting-source'
    spellId: {choice: $.bard.signature-spells.rank-1}
```
