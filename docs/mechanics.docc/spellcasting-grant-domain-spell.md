# spellcasting/grant-domain-spell

Grants the initial or advanced domain focus spell associated with a deity's domain.

Effect `grant-domain-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `sourceId` | `uuid` | yes |
| `domain` | `domain-id` | yes |
| `advanced` | `bool` | yes |

## Usage in the archive

Used by 4 rules.

Example, from `paizo-pathfinder-player-core/feat/advanced-domain.yml`:

```yaml
- key: advanced-domain-spell
  effect: spellcasting/grant-domain-spell
  inputs:
    sourceId: b7e73ea3-1be8-5215-a0c7-055d23080c56
    domain: {choice: $.cleric.advanced-domains}
    advanced: true
```
