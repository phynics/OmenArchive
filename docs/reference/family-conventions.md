# Family Conventions

This document specifies directory conventions, schemas, and authoring guidelines for each of the 13 resource families in OmenArchive.

---

## 1. Actions

- **Path**: `src/{pub}/action/{slug}.yml`
- **Schema**: [`schemas/character-action.schema.json`](../../schemas/character-action.schema.json)

```yaml
name: administer first aid
description: |
  You perform first aid on an adjacent creature...
traits:
  - manipulate
  - skill
count: two_actions
requirements: You're wearing or holding a Healer's Toolkit.
success: |
  If you're trying to stabilize...
criticalFailure: |
  If you were trying to stabilize...
```

Action fields include: `count` (`one_action`, `two_actions`, `three_actions`, `reaction`, `free_action`), `requirements`, `trigger`, `frequency`, `success`, `criticalSuccess`, `failure`, and `criticalFailure`.

---

## 2. Spells

- **Path**: `src/{pub}/spell/{slug}.yml`
- **Schema**: [`schemas/character-spell.schema.json`](../../schemas/character-spell.schema.json)

```yaml
name: fireball
rank: 3
category: spell
traditions:
  - arcane
  - primal
traits:
  - concentrate
  - fire
  - manipulate
description: |
  A roaring blast of fire erupts...
```

- `rank` is `0` for cantrips and `1`–`10` for ranked spells.
- `category` is one of `spell`, `cantrip`, `focus`, or `ritual`.
- Traditions (`arcane`, `divine`, `occult`, `primal`) stay in `traditions`.

---

## 3. Ancestries

- **Base ancestry**: `src/{pub}/ancestry/{ancestry}/{ancestry}.yml`
- **Ancestry features**: `src/{pub}/ancestry/{ancestry}/features/{slug}.yml`
- **Schemas**: [`schemas/character-ancestry.schema.json`](../../schemas/character-ancestry.schema.json) and [`schemas/character-feature.schema.json`](../../schemas/character-feature.schema.json)

```yaml
name: elf
rarity: common
hitPoints: 6
traits:
  - elf
  - humanoid
attributes:
  freeBoosts: 1
  strength: neutral
  dexterity: boost
  constitution: flaw
  intelligence: boost
  wisdom: neutral
  charisma: neutral
languages:
  - elven
  - common
speed: 30
vision: low-light
size: medium
```

Base ancestry stats live in `{ancestry}.yml`. Core fixed ancestry traits and features live under `features/`.

---

## 4. Conditions

- **Path**: `src/{pub}/condition/{slug}.yml`
- **Schema**: [`schemas/character-condition.schema.json`](../../schemas/character-condition.schema.json)

```yaml
name: frightened
valued: true
group: attitudes
description: |
  You're gripped by fear and struggle to act effectively...
```

- `valued`: `true` when the condition takes a numerical value (`frightened 2`).
- Conditions describe rule effects that other records link to (`omen://condition/frightened`).

---

## 5. Backgrounds

- **Path**: `src/{pub}/background/{slug}.yml`
- **Schema**: [`schemas/character-background.schema.json`](../../schemas/character-background.schema.json)

```yaml
name: bandit
description: |
  You eked out a living preying on travelers...
attributes:
  freeBoosts: 1
  chooseFrom:
    - charisma
    - dexterity
skillOption:
  - intimidation
loreSkill: plains
skillFeat: group coercion
```

Backgrounds with alternate choices use a `variants` array. `loreSkill` is set to `""` when the player or GM chooses the specific lore topic.

---

## 6. Classes

- **Base class**: `src/{pub}/class/{class}/{class}.yml`
- **Class features**: `src/{pub}/class/{class}/features/{slug}.yml`
- **Schemas**: [`schemas/character-class.schema.json`](../../schemas/character-class.schema.json) and [`schemas/character-feature.schema.json`](../../schemas/character-feature.schema.json)

```yaml
name: fighter
rarity: common
keyAttribute:
  - dexterity
  - strength
hitPoints: 10
gainsFeatAtFirstLevel: true
armorProficiency:
  heavy: trained
  unarmored: trained
  light: trained
  medium: trained
weaponProficiency:
  advanced: trained
  unarmored: expert
  martial: expert
  simple: expert
savingThrowProficiency:
  fortitude: expert
  reflex: expert
  will: trained
  perception: expert
additionalSkillCount: 3
```

Class options declared in `schemas/archive-format.json` live in custom child directories (such as `muses/` for bards, `rackets/` for rogues, `schools/` for wizards, and `patrons/` for witches).

---

## 7. Feats

- **Path**: `src/{pub}/feat/{slug}.yml`
- **Schema**: [`schemas/character-feat.schema.json`](../../schemas/character-feat.schema.json)

```yaml
name: fleet
level: 1
rarity: common
traits:
  - general
description: |
  You move faster on foot. You gain a +5-foot status bonus to your Speed.
```

Feats can include `alternateLevels`, `prerequisites`, `relatedArchetype`, `specialText`, and `action`.

---

## 8. Heritages and Versatile Heritages

- **Ancestry Heritage**: `src/{pub}/ancestry/{ancestry}/heritages/{slug}.yml`
- **Versatile Heritage**: `src/{pub}/versatile-heritage/{slug}.yml`
- **Schema**: [`schemas/character-heritage.schema.json`](../../schemas/character-heritage.schema.json)

```yaml
name: seer elf
ancestry: elf
rarity: common
description: |
  You possess an instinctive grasp of magical energies...
```

For versatile heritages, set `ancestry: versatile` and use inline rules to grant ancestry traits (`add-character-ancestry-trait`) and senses.

---

## 9. Archetypes

- **Archetype root**: `src/{pub}/archetype/{archetype}/{archetype}.yml`
- **Owned feats**: `src/{pub}/archetype/{archetype}/feats/{slug}.yml`
- **Schemas**: [`schemas/character-archetype.schema.json`](../../schemas/character-archetype.schema.json) and [`schemas/character-feat.schema.json`](../../schemas/character-feat.schema.json)

```yaml
name: bard
description: |
  You have studied the arts of performance and occult magic...
entryFeat: omen://archetype/bard/feats/bard-dedication?source=paizo-pathfinder-player-core
```

Archetypes are bundles whose owned feats live in `feats/`. The `entryFeat` links to the dedication feat.

---

## 10. Items and Equipment

- **Path**: `src/{pub}/item/{slug}.yml`
- **Schema**: [`schemas/character-item.schema.json`](../../schemas/character-item.schema.json)

```yaml
name: longsword
type: weapon
physical:
  bulk: "1"
  price:
    gp: 1
  hardness: 0
  hitPoints: 0
  usage: held-in-one-hand
details:
  category: martial
  group: sword
  damage:
    die: d8
    type: slashing
  traits:
    - versatile-p
description: |
  A longsword is a versatile blade with a single- or double-edged blade...
```

Equipment uses a single canonical `item/` family. `type` designates `equipment`, `weapon`, `armor`, `shield`, `consumable`, `container`, `treasure`, or `kit`.

---

## 11. Domains

- **Path**: `src/{pub}/domain/{slug}.yml`
- **Schema**: [`schemas/character-domain.schema.json`](../../schemas/character-domain.schema.json)

```yaml
name: air
description: |
  You have power over the winds, skies, and air.
spells:
  initial: omen://spell/air-cushion?source=paizo-pathfinder-player-core
  advanced: omen://spell/updraft?source=paizo-pathfinder-player-core
```

---

## 12. Companions

- **Path**: `src/{pub}/companion/{slug}.yml`
- **Schema**: [`schemas/character-companion.schema.json`](../../schemas/character-companion.schema.json)

Describes animal companion and familiar templates, basic statistics, attacks, and support benefits.

---

## 13. Features

- **Class Feature**: `src/{pub}/class/{class}/features/{slug}.yml`
- **Ancestry Feature**: `src/{pub}/ancestry/{ancestry}/features/{slug}.yml`
- **Schema**: [`schemas/character-feature.schema.json`](../../schemas/character-feature.schema.json)

Features represent innate, progressing, or granted abilities belonging to an ancestry, class, or custom class group.

## Rules

- **Path**: `src/{pub}/rule/{slug}.yml`
- **Schema**: [`schemas/character-rule.schema.json`](../../schemas/character-rule.schema.json)

```yaml
name: cover
description: Cover is the protection a creature gets from an obstacle...
```

- A rule is reference text for a general rule (cover, flanking, degrees of success). It has no mechanics.
- Descriptions link to a rule as `omen://rule/cover`.
- Rule records are hand-authored from the book's rules text; a refresh doesn't generate or change them.

