# spellcasting/mark-signature-spell@2

Designates a known spell in a spontaneous caster's repertoire as a signature spell, allowing heightening without separate learning.

Effect `mark-signature-spell`, revision 2, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spell` | `spell-id` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Writes

- domain `signature-spell`, name input `spell`

## Usage in the archive

Used by 30 rules.

Example, from `paizo-pathfinder-player-core-2/class/oracle/features/signature-spells.yml`:

```yaml
- effect: spellcasting/mark-signature-spell@2
  inputs:
    source: oracle-spellcasting
    spell:
      choice: $.oracle.signature-spells.rank-1
  key: mark-signature-spell-1
  level: 3
```
