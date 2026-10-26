# Module spellcasting

Module `me.atkn.omen.pf2e.playercore-spellcasting`, revision 1. Depends on: `me.atkn.omen.pf2e.playercore`.

Rules refer to it with the alias `spellcasting`, declared in a publication's `mechanicsModules`.

## Value types

| Type | Rev | Shape |
|---|---|---|
| `cast-frequency` | 1 | `{"properties":{"uses":{"kind":"integer"},"kind":{"kind":"enum","values":["atWill","perDay","focus"]}},"required":["kind"],"kind":"object","additionalProperties":false}` |
| `casting-kind` | 1 | `{"kind":"enum","values":["prepared","spontaneous","innate","focus"]}` |
| `rank-policy` | 1 | `{"properties":{"rank":{"kind":"integer"},"kind":{"kind":"enum","values":["fixed","cantrip"]}},"required":["kind"],"kind":"object","additionalProperties":false}` |
| `resource-filter` | 1 | `{"additionalProperties":true,"kind":"object","properties":{},"required":[]}` |
| `spell-id` | 1 | `{"kind":"string"}` |
| `spell-id-list` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `tradition` | 1 | `{"values":["arcane","divine","occult","primal"],"kind":"enum"}` |

## Effects

- <doc:spellcasting-add-focus-point>
- <doc:spellcasting-add-known-spell>
- <doc:spellcasting-add-known-spell-list>
- <doc:spellcasting-add-spell-list>
- <doc:spellcasting-configure-source>
- <doc:spellcasting-grant-domain-spell>
- <doc:spellcasting-grant-focus-spell>
- <doc:spellcasting-grant-innate-spell>
- <doc:spellcasting-grant-slot>
- <doc:spellcasting-grant-spell>
- <doc:spellcasting-increase-proficiency>
- <doc:spellcasting-increase-source-proficiency>
- <doc:spellcasting-increase-spell-proficiency>
- <doc:spellcasting-mark-signature-spell>
- <doc:spellcasting-modify-innate-sources>
