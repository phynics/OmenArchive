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
| `armor-designation` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"armorKind":{"kind":"enum","values":["unarmored","light","medium","heavy"]},"kind":{"kind":"enum","values":["type","specific"]},"name":{"kind":"string"}},"required":["kind"]}` |
| `attribute` | 1 | `{"kind":"enum","values":["str","dex","con","int","wis","cha"]}` |
| `bool` | 1 | `{"kind":"boolean"}` |
| `crafting-specialty` | 1 | `{"kind":"vocabulary","name":"crafting-specialty"}` |
| `domain-id` | 1 | `{"kind":"string"}` |
| `feat-choice-settings` | 1 | `{"additionalProperties":true,"kind":"object","properties":{},"required":[]}` |
| `feat-id` | 1 | `{"kind":"string"}` |
| `feature-id` | 1 | `{"kind":"string"}` |
| `formula-families` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `heritage-id` | 1 | `{"kind":"string"}` |
| `int` | 1 | `{"kind":"integer"}` |
| `item-id` | 1 | `{"kind":"string"}` |
| `item-id-list` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `list-entry` | 1 | `{"kind":"any"}` |
| `list-item` | 1 | `{"kind":"any"}` |
| `list-path` | 1 | `{"kind":"string"}` |
| `list-value-type` | 1 | `{"kind":"any"}` |
| `proficiency-rank` | 1 | `{"kind":"enum","values":[0,2,4,6,8]}` |
| `resource-filter` | 1 | `{"additionalProperties":true,"kind":"object","properties":{},"required":[]}` |
| `roll-description` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"description":{"items":{"additionalProperties":false,"kind":"object","properties":{"action":{"additionalProperties":false,"kind":"object","properties":{"_0":{"kind":"string"}},"required":["_0"]},"anyAttack":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"anyAttribute":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"anyNonPerceptionSavingThrow":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"anySavingThrow":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"anySkill":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"attribute":{"additionalProperties":false,"kind":"object","properties":{"_0":{"kind":"enum","values":["str","dex","con","int","wis","cha"]}},"required":["_0"]},"perception":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"savingThrow":{"additionalProperties":false,"kind":"object","properties":{"_0":{"kind":"enum","values":["fortitude","reflex","will","perception"]}},"required":["_0"]},"skill":{"additionalProperties":false,"kind":"object","properties":{"_0":{"additionalProperties":false,"kind":"object","properties":{"acrobatics":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"arcana":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"athletics":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"crafting":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"deception":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"diplomacy":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"intimidation":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"lore":{"additionalProperties":false,"kind":"object","properties":{"_0":{"kind":"string"}},"required":["_0"]},"medicine":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"nature":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"occultism":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"performance":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"religion":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"society":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"stealth":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"survival":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"thievery":{"additionalProperties":false,"kind":"object","properties":{},"required":[]}},"required":[]}},"required":["_0"]},"speed":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"spellAttack":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"weaponAttack":{"additionalProperties":false,"kind":"object","properties":{"_0":{"additionalProperties":false,"kind":"object","properties":{"filter":{"additionalProperties":false,"kind":"object","properties":{"_0":{"additionalProperties":false,"kind":"object","properties":{"group":{"kind":"vocabulary","name":"weapon-group"},"kind":{"additionalProperties":false,"kind":"object","properties":{"advanced":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"any":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"anyNonAdvanced":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"martial":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"simple":{"additionalProperties":false,"kind":"object","properties":{},"required":[]},"unarmed":{"additionalProperties":false,"kind":"object","properties":{},"required":[]}},"required":[]}},"required":["group","kind"]}},"required":["_0"]},"specific":{"additionalProperties":false,"kind":"object","properties":{"_0":{"kind":"string"}},"required":["_0"]}},"required":[]}},"required":["_0"]}},"required":[]},"kind":"array"}},"required":[]}` |
| `saving-throw` | 1 | `{"kind":"enum","values":["fortitude","reflex","will","perception"]}` |
| `sheet-value` | 1 | `{"kind":"any"}` |
| `skill` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"kind":{"kind":"enum","values":["acrobatics","arcana","athletics","crafting","deception","diplomacy","intimidation","medicine","nature","occultism","performance","religion","society","stealth","survival","thievery","lore"]},"name":{"kind":"string"}},"required":["kind"]}` |
| `string` | 1 | `{"kind":"string"}` |
| `terrain` | 1 | `{"kind":"vocabulary","name":"terrain"}` |
| `uuid` | 1 | `{"kind":"string"}` |
| `weapon-designation` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"kind":{"kind":"enum","values":["filter","specific"]},"name":{"kind":"string"},"weaponGroup":{"kind":"vocabulary","name":"weapon-group"},"weaponKind":{"kind":"enum","values":["unarmed","simple","martial","advanced","any","any-non-advanced"]}},"required":["kind"]}` |
| `weapon-group` | 1 | `{"kind":"vocabulary","name":"weapon-group"}` |
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
