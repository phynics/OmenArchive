# Module core

Module `me.atkn.omen.pf2e.playercore`, revision 1. Depends on: none.

Rules refer to it with the alias `core`, declared in a publication's `mechanicsModules`.

## State keys

- `assurance-skills`: `assurance-skills`
- `terrain-stalker-terrains`: `terrain-stalker-terrains`
- `crafting-abilities`: `crafting-abilities`
- `formula-families`: `formula-families`

## Value types

| Type | Rev | Shape |
|---|---|---|
| `action-id` | 1 | `{"kind":"string"}` |
| `armor-designation` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"name":{"kind":"string"},"kind":{"kind":"enum","values":["type","specific"]},"armorKind":{"kind":"enum","values":["unarmored","light","medium","heavy"]}},"required":["kind"]}` |
| `armor-kind` | 1 | `{"values":["unarmored","light","medium","heavy"],"kind":"enum"}` |
| `assurance-skills` | 1 | `{"items":{"properties":{"kind":{"values":["acrobatics","arcana","athletics","crafting","deception","diplomacy","intimidation","medicine","nature","occultism","performance","religion","society","stealth","survival","thievery","lore"],"kind":"enum"},"name":{"kind":"string"}},"additionalProperties":false,"required":["kind"],"kind":"object"},"kind":"array"}` |
| `attribute` | 1 | `{"values":["str","dex","con","int","wis","cha"],"kind":"enum"}` |
| `bool` | 1 | `{"kind":"boolean"}` |
| `character-feature` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"rules":{"items":{"properties":{},"kind":"object","required":[],"additionalProperties":true},"kind":"array"},"actionDefinition":{"properties":{},"kind":"object","required":[],"additionalProperties":true},"traits":{"items":{"kind":"string"},"kind":"array"},"sourceID":{"kind":"string"},"id":{"kind":"string"},"text":{"kind":"string"},"source":{"properties":{},"additionalProperties":true,"required":[],"kind":"object"},"parentPath":{"kind":"string"},"name":{"kind":"string"},"rarity":{"values":["common","uncommon","rare","unique"],"kind":"enum"},"level":{"kind":"integer"}},"required":["actionDefinition","id","level","name","rules","text","traits"]}` |
| `crafting-abilities` | 1 | `{"items":{"properties":{"maxSlotsExpression":{"kind":"string"},"slug":{"kind":"string"},"isDailyPreparation":{"kind":"boolean"},"craftableItems":{"kind":"array","items":{"kind":"string"}},"label":{"kind":"string"}},"additionalProperties":false,"required":["craftableItems","isDailyPreparation","label","maxSlotsExpression","slug"],"kind":"object"},"kind":"array"}` |
| `crafting-specialty` | 1 | `{"values":["alchemy","artistry","blacksmithing","bookmaking","glassmaking","leatherworking","pottery","shipbuilding","stonemasonry","tailoring","weaving","woodworking"],"kind":"enum"}` |
| `domain-id` | 1 | `{"kind":"string"}` |
| `feat-choice-settings` | 1 | `{"additionalProperties":true,"kind":"object","properties":{},"required":[]}` |
| `feat-id` | 1 | `{"kind":"string"}` |
| `feature-id` | 1 | `{"kind":"string"}` |
| `formula-families` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `heritage-id` | 1 | `{"kind":"string"}` |
| `int` | 1 | `{"kind":"integer"}` |
| `item-id` | 1 | `{"kind":"string"}` |
| `item-id-list` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `placeholder` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"name":{"kind":"string"},"id":{"kind":"string"}},"required":[]}` |
| `proficiency-rank` | 1 | `{"values":[0,2,4,6,8],"kind":"enum"}` |
| `roll-description` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"description":{"items":{"required":[],"additionalProperties":true,"kind":"object","properties":{}},"kind":"array"}},"required":[]}` |
| `roll-modifier` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"numeric":{"properties":{"type":{"values":["item","status","circumstance","untyped"],"kind":"enum"},"amount":{"kind":"integer"},"applicability":{"required":["kind"],"kind":"object","additionalProperties":false,"properties":{"kind":{"values":["always","situational"],"kind":"enum"},"description":{"kind":"string"}}}},"kind":"object","required":["amount","applicability","type"],"additionalProperties":false},"id":{"kind":"string"},"description":{"kind":"string"},"targetRoll":{"properties":{},"kind":"object","required":[],"additionalProperties":true}},"required":[]}` |
| `roll-modifier-numeric` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"amount":{"kind":"integer"},"applicability":{"properties":{"description":{"kind":"string"},"kind":{"values":["always","situational"],"kind":"enum"}},"kind":"object","required":["kind"],"additionalProperties":false},"type":{"kind":"enum","values":["item","status","circumstance","untyped"]}},"required":["amount","applicability","type"]}` |
| `saving-throw` | 1 | `{"values":["fortitude","reflex","will","perception"],"kind":"enum"}` |
| `sheet-value` | 1 | `{"kind":"any"}` |
| `skill` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"kind":{"kind":"enum","values":["acrobatics","arcana","athletics","crafting","deception","diplomacy","intimidation","medicine","nature","occultism","performance","religion","society","stealth","survival","thievery","lore"]},"name":{"kind":"string"}},"required":["kind"]}` |
| `skill-increase` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"selected":{"properties":{},"kind":"object","required":[],"additionalProperties":true},"id":{"kind":"string"},"proficiencyCap":{"kind":"enum","values":[0,2,4,6,8]}},"required":["id","proficiencyCap"]}` |
| `string` | 1 | `{"kind":"string"}` |
| `terrain` | 1 | `{"values":["aquatic","arctic","desert","forest","mountain","plains","sky","swamp","underground"],"kind":"enum"}` |
| `terrain-stalker-terrains` | 1 | `{"items":{"kind":"string"},"kind":"array"}` |
| `type-of-value` | 1 | `{"kind":"string"}` |
| `uuid` | 1 | `{"kind":"string"}` |
| `weapon-designation` | 1 | `{"additionalProperties":false,"kind":"object","properties":{"weaponKind":{"kind":"enum","values":["unarmed","simple","martial","advanced","any","any-non-advanced"]},"weaponGroup":{"kind":"enum","values":["sword","brawling","flail","knife","club","dart","spear","axe","polearm","hammer","pick","shield","bow","bomb","any"]},"kind":{"kind":"enum","values":["filter","specific"]},"name":{"kind":"string"}},"required":["kind"]}` |
| `weapon-group` | 1 | `{"values":["sword","brawling","flail","knife","club","dart","spear","axe","polearm","hammer","pick","shield","bow","bomb","any"],"kind":"enum"}` |
| `weapon-kind` | 1 | `{"values":["unarmed","simple","martial","advanced","any","any-non-advanced"],"kind":"enum"}` |
| `weapon-reference` | 1 | `{"kind":"string"}` |

## Effects

- <doc:core-add-action>
- <doc:core-add-armor-group-proficiency-2>
- <doc:core-add-armor-proficiency>
- <doc:core-add-assurance>
- <doc:core-add-base-speed>
- <doc:core-add-character-ancestry-trait>
- <doc:core-add-character-trait>
- <doc:core-add-chosen-weapon-proficiency>
- <doc:core-add-class-dc>
- <doc:core-add-crafting-ability>
- <doc:core-add-feat-2>
- <doc:core-add-feat-ancestry>
- <doc:core-add-feature>
- <doc:core-add-feature-by-id>
- <doc:core-add-formulas>
- <doc:core-add-heritage-by-id>
- <doc:core-add-hit-points>
- <doc:core-add-hit-points-per-count>
- <doc:core-add-hit-points-per-level>
- <doc:core-add-item-2>
- <doc:core-add-language>
- <doc:core-add-lore-skill-increase>
- <doc:core-add-membership>
- <doc:core-add-placeholder>
- <doc:core-add-resistance-2>
- <doc:core-add-roll-modifier-2>
- <doc:core-add-saving-throw>
- <doc:core-add-sense>
- <doc:core-add-skill-increase>
- <doc:core-add-specialty-crafting>
- <doc:core-add-speed-modifier>
- <doc:core-add-terrain-expertise>
- <doc:core-add-terrain-stalker>
- <doc:core-add-weapon-critical-specialization>
- <doc:core-add-weapon-die-step>
- <doc:core-add-weapon-group-proficiency>
- <doc:core-add-weapon-proficiency>
- <doc:core-extend-class-key-attribute>
- <doc:core-set-ancestry-hit-points>
- <doc:core-substitute-skill>
