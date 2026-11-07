# Module core

Module `me.atkn.omen.pf2e.playercore`, revision 1. Depends on: none.

Rules refer to it with the alias `core`, declared in a publication's `mechanicsModules`.

## State keys

- `formula-families`: `formula-families`

## Lists

Character lists the module declares for the engine. Rules add to and read them like a list a record declares (<doc:character-lists>).

| List | Holds | Label |
|---|---|---|
| `$.ancestry.feat-ancestries` | `string` | Feat ancestries |
| `$.class.key-attribute-options` | `attribute` | Key attribute options |
| `$.skills.substitutions` | entries of `skill` (`skill`), `substitute` (`skill`) | Skill substitutions |
| `$.crafting.formulas` | any record under `omen://item` | Formulas |

## Value types

| Type | Rev | Shape |
|---|---|---|
| `action-id` | 1 | `{"kind":"string"}` |
| `armor-designation` | 1 | `{"kind":"object","required":["kind"],"properties":{"name":{"kind":"string"},"kind":{"kind":"enum","values":["type","specific"]},"armorKind":{"kind":"enum","values":["unarmored","light","medium","heavy"]}},"additionalProperties":false}` |
| `attribute` | 1 | `{"values":["str","dex","con","int","wis","cha"],"kind":"enum"}` |
| `bool` | 1 | `{"kind":"boolean"}` |
| `crafting-specialty` | 1 | `{"name":"crafting-specialty","kind":"vocabulary"}` |
| `domain-id` | 1 | `{"kind":"string"}` |
| `feat-choice-settings` | 1 | `{"required":[],"kind":"object","additionalProperties":true,"properties":{}}` |
| `feat-id` | 1 | `{"kind":"string"}` |
| `feature-id` | 1 | `{"kind":"string"}` |
| `formula-families` | 1 | `{"kind":"array","items":{"kind":"string"}}` |
| `heritage-id` | 1 | `{"kind":"string"}` |
| `int` | 1 | `{"kind":"integer"}` |
| `item-id` | 1 | `{"kind":"string"}` |
| `item-id-list` | 1 | `{"kind":"array","items":{"kind":"string"}}` |
| `list-entry` | 1 | `{"kind":"any"}` |
| `list-item` | 1 | `{"kind":"any"}` |
| `list-path` | 1 | `{"kind":"string"}` |
| `list-value-type` | 1 | `{"kind":"any"}` |
| `proficiency-rank` | 1 | `{"kind":"enum","values":[0,2,4,6,8]}` |
| `resource-filter` | 1 | `{"properties":{},"kind":"object","additionalProperties":true,"required":[]}` |
| `roll-description` | 1 | `{"required":[],"kind":"object","additionalProperties":false,"properties":{"description":{"kind":"array","items":{"required":[],"properties":{"skill":{"kind":"object","required":["_0"],"properties":{"_0":{"kind":"object","properties":{"performance":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"occultism":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"thievery":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"nature":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"athletics":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"arcana":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"medicine":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"deception":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"religion":{"required":[],"kind":"object","additionalProperties":false,"properties":{}},"crafting":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"acrobatics":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"survival":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"society":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"stealth":{"required":[],"kind":"object","additionalProperties":false,"properties":{}},"diplomacy":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"lore":{"required":["_0"],"kind":"object","additionalProperties":false,"properties":{"_0":{"kind":"string"}}},"intimidation":{"kind":"object","properties":{},"additionalProperties":false,"required":[]}},"additionalProperties":false,"required":[]}},"additionalProperties":false},"anySkill":{"kind":"object","required":[],"properties":{},"additionalProperties":false},"anyAttribute":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"weaponAttack":{"kind":"object","properties":{"_0":{"kind":"object","required":[],"properties":{"specific":{"required":["_0"],"additionalProperties":false,"kind":"object","properties":{"_0":{"kind":"string"}}},"filter":{"required":["_0"],"additionalProperties":false,"kind":"object","properties":{"_0":{"additionalProperties":false,"properties":{"group":{"name":"weapon-group","kind":"vocabulary"},"kind":{"properties":{"martial":{"required":[],"kind":"object","properties":{},"additionalProperties":false},"anyNonAdvanced":{"additionalProperties":false,"required":[],"properties":{},"kind":"object"},"advanced":{"required":[],"kind":"object","properties":{},"additionalProperties":false},"any":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"simple":{"kind":"object","properties":{},"additionalProperties":false,"required":[]},"unarmed":{"additionalProperties":false,"required":[],"properties":{},"kind":"object"}},"required":[],"additionalProperties":false,"kind":"object"}},"required":["group","kind"],"kind":"object"}}}},"additionalProperties":false}},"required":["_0"],"additionalProperties":false},"anyAttack":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"savingThrow":{"kind":"object","required":["_0"],"properties":{"_0":{"kind":"enum","values":["fortitude","reflex","will","perception"]}},"additionalProperties":false},"attribute":{"properties":{"_0":{"values":["str","dex","con","int","wis","cha"],"kind":"enum"}},"additionalProperties":false,"kind":"object","required":["_0"]},"perception":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"anySavingThrow":{"kind":"object","required":[],"properties":{},"additionalProperties":false},"speed":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"anyNonPerceptionSavingThrow":{"properties":{},"additionalProperties":false,"kind":"object","required":[]},"action":{"properties":{"_0":{"kind":"string"}},"additionalProperties":false,"kind":"object","required":["_0"]},"spellAttack":{"properties":{},"additionalProperties":false,"kind":"object","required":[]}},"kind":"object","additionalProperties":false}}}}` |
| `saving-throw` | 1 | `{"kind":"enum","values":["fortitude","reflex","will","perception"]}` |
| `sheet-value` | 1 | `{"kind":"any"}` |
| `skill` | 1 | `{"kind":"object","required":["kind"],"properties":{"name":{"kind":"string"},"kind":{"kind":"enum","values":["acrobatics","arcana","athletics","crafting","deception","diplomacy","intimidation","medicine","nature","occultism","performance","religion","society","stealth","survival","thievery","lore"]}},"additionalProperties":false}` |
| `string` | 1 | `{"kind":"string"}` |
| `terrain` | 1 | `{"kind":"vocabulary","name":"terrain"}` |
| `uuid` | 1 | `{"kind":"string"}` |
| `weapon-designation` | 1 | `{"required":["kind"],"properties":{"kind":{"values":["filter","specific"],"kind":"enum"},"weaponKind":{"values":["unarmed","simple","martial","advanced","any","any-non-advanced"],"kind":"enum"},"name":{"kind":"string"},"weaponGroup":{"name":"weapon-group","kind":"vocabulary"}},"kind":"object","additionalProperties":false}` |
| `weapon-group` | 1 | `{"name":"weapon-group","kind":"vocabulary"}` |
| `weapon-kind` | 1 | `{"kind":"enum","values":["unarmed","simple","martial","advanced","any","any-non-advanced"]}` |
| `weapon-reference` | 1 | `{"kind":"string"}` |

## Effects

- <doc:core-add-action-2>
- <doc:core-add-armor-proficiency-3>
- <doc:core-add-class-dc-2>
- <doc:core-add-feat-3>
- <doc:core-add-feature-2>
- <doc:core-add-formulas>
- <doc:core-add-heritage>
- <doc:core-add-hit-points-2>
- <doc:core-add-item-3>
- <doc:core-add-modifier-2>
- <doc:core-add-note>
- <doc:core-add-perception>
- <doc:core-add-resistance-2>
- <doc:core-add-resource-pool>
- <doc:core-add-saving-throw-2>
- <doc:core-add-sense-2>
- <doc:core-add-skill-increase-2>
- <doc:core-add-specialty-crafting>
- <doc:core-add-speed>
- <doc:core-add-terrain-expertise>
- <doc:core-add-to-list>
- <doc:core-add-trait>
- <doc:core-add-weapon-critical-specialization>
- <doc:core-add-weapon-die-step>
- <doc:core-add-weapon-proficiency-3>
- <doc:core-declare-list>
- <doc:core-extend-class-key-attribute>
- <doc:core-substitute-skill>
