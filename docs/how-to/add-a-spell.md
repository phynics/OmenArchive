# How-To: Add a Spell

This guide explains how to add a cantrip, focus spell, ritual, or standard ranked spell.

## 1. File Location and Slug

Spells are placed under `src/{publication}/spell/{slug}.yml`.
Example: `src/paizo-pathfinder-player-core/spell/guidance.yml`

## 2. Author the Spell YAML

Create the YAML file conforming to [`schemas/character-spell.schema.json`](../../schemas/character-spell.schema.json):

```yaml
name: guidance
rank: 0
category: cantrip
traditions:
  - divine
  - occult
  - primal
traits:
  - cantrip
  - concentrate
cast:
  actions: one_action
range: 30 feet
target: 1 creature
duration: until the start of your next turn
description: |
  You look to divine guidance to help you...
```

### Ranked Spell with Heightening Example

```yaml
name: heal
rank: 1
category: spell
traditions:
  - divine
  - primal
traits:
  - healing
  - manipulate
  - vitality
cast:
  actions: one_to_three_actions
range: touch or 30 feet
description: |
  You channel positive vitality to heal the living or harm the undead...
heightening:
  interval:
    level: 1
    damage: 1d8
```

### Guidelines
- **`rank`**: Use `0` for cantrips; integers `1` through `10` for leveled spells.
- **`category`**: Choose from `cantrip`, `spell`, `focus`, or `ritual`.
- **`traditions`**: Array containing any of `arcane`, `divine`, `occult`, or `primal`.
- **No Embedded Scripting**: Do not include raw roll macros or Foundry script snippets. Describe mechanics clearly in `description`.

## 3. Validate

```bash
node scripts/check-schemas.mjs src/paizo-pathfinder-player-core/spell/guidance.yml
```

## 4. Commit

```bash
git add src/paizo-pathfinder-player-core/spell/guidance.yml
git commit -m "Add Guidance cantrip"
```
