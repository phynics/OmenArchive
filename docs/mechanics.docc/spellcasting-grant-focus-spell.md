# spellcasting/grant-focus-spell

Grants a focus spell to a spellcasting source and establishes its focus cantrip or focus spell scaling.

Effect `grant-focus-spell`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `spellId` | `spell-id` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

This is the only way to grant a focus spell. The spell must be a focus spell; each rule and each copy of a feat makes its own grant. The character's focus pool is derived from the grants: one point for each focus spell granted, up to 3, and focus cantrips cast at will add nothing.

A domain spell is the field of a chosen domain, read with `{choice: <path>, field: <name>}` or its short form `<path>.<name>` (see Explicit forms in the rules reference):

```yaml
- key: domain-spell
  effect: spellcasting/grant-focus-spell
  inputs:
    source: cleric-focus-spells
    spellId: $.cleric.domains.domainSpell
```

## Usage in the archive

Used by 121 rules.

Example, from `paizo-pathfinder-player-core/feat/masterful-warden.yml`:

```yaml
- key: grant-warden-spell
  effect: spellcasting/grant-focus-spell
  inputs:
    source: ranger-focus-spells
    spellId: {choice: $.feat.masterful-warden.spell}
```
