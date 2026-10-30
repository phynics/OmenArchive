# spellcasting/grant-domain-spell

Grants the initial or advanced domain focus spell associated with a deity's domain.

Effect `grant-domain-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `domain` | `domain-id` | yes |
| `advanced` | `bool` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/feat/advanced-domain.yml`:

```yaml
- key: advanced-domain-spell
  effect: spellcasting/grant-domain-spell
  inputs:
    source: cleric-focus-spells
    domain: {choice: $.cleric.advanced-domains}
    advanced: true
```
