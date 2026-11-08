# Module spellcasting

Module `me.atkn.omen.pf2e.playercore-spellcasting`, revision 1. Depends on: `me.atkn.omen.pf2e.playercore`.

Rules refer to it with the alias `spellcasting`, declared in a publication's `mechanicsModules`.

## Value types

| Type | Rev | Shape |
|---|---|---|
| `cast-frequency` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"kind":{"kind":"enum","values":["atWill","perDay","focus"]},"uses":{"kind":"integer"}},"required":["kind"]}` |
| `casting-kind` | 1 | `{"kind":"enum","values":["prepared","spontaneous","innate","focus"]}` |
| `rank-policy` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"kind":{"kind":"enum","values":["fixed","cantrip"]},"rank":{"kind":"integer"}},"required":["kind"]}` |
| `resource-filter` | 1 | `{"additionalProperties":true,"kind":"object","properties":{},"required":[]}` |
| `spell-id` | 1 | `{"kind":"string"}` |
| `spell-id-list` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `spell-pick` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"kind":{"kind":"enum","values":["cantrip","rank","upTo"]},"rank":{"kind":"integer"}},"required":["kind"]}` |
| `tradition` | 1 | `{"kind":"enum","values":["arcane","divine","occult","primal"]}` |

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
