# How-To: Add a Feat

This guide explains how to add a general, skill, or ancestry feat to an existing publication.

## 1. Determine Location and Slug

Feats live under `src/{publication}/feat/{slug}.yml`.
The slug should be lowercase kebab-case matching the Remaster feat name:
`src/paizo-pathfinder-player-core/feat/fleet.yml`

## 2. Author the Feat YAML

Create the YAML file conforming to [`schemas/character-feat.schema.json`](../../schemas/character-feat.schema.json):

```yaml
name: fleet
level: 1
rarity: common
traits:
  - general
description: |
  You move more quickly on foot. You gain a +5-foot status bonus to your Speed.
rules:
  - key: fleet-speed
    effect: core/add-speed-bonus
    inputs:
      type: land
      bonus: 5
      kind: status
```

### Key Considerations
- **`traits`**: All traits must be lowercase strings matching official game terms (`general`, `skill`, `fighter`, `elf`).
- **`prerequisites`**: Use human-readable strings, or structured objects if machine validation is supported.
- **`action`**: If the feat provides an action or reaction, specify `action: { count: reaction }` or similar. Omit `action:` if the feat is passive.
- **`rules`**: See [Rules and Effect Inputs](../reference/rules-and-inputs.md) and [Mechanics Catalog](../mechanics.docc/) for available effects.

## 3. Validate

```bash
node scripts/check-schemas.mjs src/paizo-pathfinder-player-core/feat/fleet.yml
```

If OmenArchiveKit is installed:
```bash
./scripts/validate.sh
```

## 4. Commit

```bash
git add src/paizo-pathfinder-player-core/feat/fleet.yml
git commit -m "Add Fleet general feat"
```
