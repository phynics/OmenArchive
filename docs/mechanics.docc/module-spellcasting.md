# Module spellcasting

Module `me.atkn.omen.pf2e.playercore-spellcasting`, revision 1. Depends on: `me.atkn.omen.pf2e.playercore`.

Rules refer to it with the alias `spellcasting`, declared in a publication's `mechanicsModules`.

## Value types

| Type | Rev | Shape |
|---|---|---|
| `cast-frequency` | 1 | `{"kind":"object","required":["kind"],"properties":{"kind":{"kind":"enum","values":["atWill","perDay","focus"]},"uses":{"kind":"integer"}},"additionalProperties":false}` |
| `casting-kind` | 1 | `{"values":["prepared","spontaneous","innate","focus"],"kind":"enum"}` |
| `rank-policy` | 1 | `{"properties":{"kind":{"values":["fixed","cantrip"],"kind":"enum"},"rank":{"kind":"integer"}},"kind":"object","additionalProperties":false,"required":["kind"]}` |
| `resource-filter` | 1 | `{"required":[],"properties":{},"additionalProperties":true,"kind":"object"}` |
| `spell-id` | 1 | `{"kind":"string"}` |
| `spell-id-list` | 1 | `{"kind":"array","items":{"kind":"string"}}` |
| `spell-pick` | 1 | `{"kind":"object","required":["kind"],"properties":{"kind":{"kind":"enum","values":["cantrip","rank","upTo"]},"rank":{"kind":"integer"}},"additionalProperties":false}` |
| `tradition` | 1 | `{"values":["arcane","divine","occult","primal"],"kind":"enum"}` |

## Effects

- <doc:spellcasting-add-known-spell>
- <doc:spellcasting-add-spell-list>
- <doc:spellcasting-allow-known-spells>
- <doc:spellcasting-configure-source>
- <doc:spellcasting-grant-focus-spell-2>
- <doc:spellcasting-grant-innate-spell-2>
- <doc:spellcasting-grant-slot>
- <doc:spellcasting-grant-spell-2>
- <doc:spellcasting-increase-spell-proficiency-2>
- <doc:spellcasting-mark-signature-spell-2>
- <doc:spellcasting-modify-innate-sources>
