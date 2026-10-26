# How-To: Add a Class Feature or Archetype

This guide explains how to add fixed or optional class features to a class bundle, or author a new archetype bundle.

---

## Part 1: Adding a Class Feature

Classes in OmenArchive do not declare inline rules. All progression mechanics are authored as separate feature files.

### 1. Directory Structure

- Fixed Class Features: `src/{publication}/class/{class}/features/{slug}.yml`
- Subclass / Choice Options: `src/{publication}/class/{class}/{group}/{slug}.yml`
  (e.g., `muses/`, `orders/`, `rackets/`, `schools/`)

### 2. Authoring the Feature YAML

Features conform to [`schemas/character-feature.schema.json`](../../schemas/character-feature.schema.json):

```yaml
name: brave
level: 3
traits:
  - fighter
description: |
  You have steeled yourself against fear...
rules:
  - key: brave-will-bonus
    effect: core/add-roll-modifier
    inputs:
      target: will
      modifier: 1
      kind: circumstance
```

---

## Part 2: Adding an Archetype Bundle

Archetypes are bundles containing an archetype root record and a `feats/` directory.

### 1. Create the Directory Structure

```text
src/{publication}/archetype/{archetype-slug}/
├── {archetype-slug}.yml
└── feats/
    ├── {archetype-slug}-dedication.yml
    └── ...
```

### 2. Author the Archetype Root

Create `src/{publication}/archetype/{archetype-slug}/{archetype-slug}.yml` matching [`schemas/character-archetype.schema.json`](../../schemas/character-archetype.schema.json):

```yaml
name: medic
description: |
  You are an expert field medic...
entryFeat: omen://archetype/medic/feats/medic-dedication?source=paizo-pathfinder-player-core-2
progression:
  dedicationLockFeatCount: 3
```

### 3. Author the Feats

Place owned feats under `feats/` conforming to [`schemas/character-feat.schema.json`](../../schemas/character-feat.schema.json):

```yaml
# src/.../archetype/medic/feats/medic-dedication.yml
name: medic dedication
level: 2
rarity: archetype
traits:
  - archetype
  - dedication
prerequisites:
  - text: trained in Medicine
    hasSkillProficiency: { skill: medicine, proficiency: trained }
description: |
  You have dedicated your studies to battlefield medicine...
```

Notice that archetype-owned feats inside the bundle do **not** write `relatedArchetype`: the directory structure defines ownership.

## 4. Validate and Commit

```bash
node scripts/check-schemas.mjs src/{publication}/archetype/{slug}/
git add src/{publication}/archetype/{slug}/
git commit -m "Add Medic archetype bundle"
```
