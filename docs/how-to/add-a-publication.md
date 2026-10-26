# How-To: Add a Publication

This guide explains how to register and initialize a new publication directory in OmenArchive.

## 1. Choose the Canonical Publication ID

The publication ID must follow the standard convention: `<publisher>-<game-line>-<title>` in lowercase kebab-case.
Example: `paizo-pathfinder-howl-of-the-wild`

## 2. Create the Directory and `publication.yml`

Create directory `src/{publication-id}/` and add `publication.yml` conforming to [`schemas/publication.schema.json`](../../schemas/publication.schema.json):

```yaml
id: paizo-pathfinder-howl-of-the-wild
publisher: Paizo
title: Pathfinder Howl of the Wild
code: "21-08"
isbn: "978-1-64078-600-4"
releaseDate: "2024-05-29"
license: ORC
mechanicsModules:
  core: me.atkn.omen.pf2e.playercore
  spellcasting: me.atkn.omen.pf2e.playercore-spellcasting
externalRecords: []
```

## 3. Create Resource Subdirectories

Add subdirectories for the resource families contained in this book:
```bash
mkdir -p src/paizo-pathfinder-howl-of-the-wild/{action,ancestry,archetype,feat,item,spell}
```

## 4. Update Collections (Optional)

If the publication belongs to a core or themed collection, update the relevant file in `collections/` (e.g. `collections/pathfinder-core.yml`).

## 5. Validate

Run the schema check on the new publication:
```bash
node scripts/check-schemas.mjs src/paizo-pathfinder-howl-of-the-wild/publication.yml
```

Verify the whole archive:
```bash
node scripts/check-schemas.mjs
```

## 6. Commit

```bash
git add src/paizo-pathfinder-howl-of-the-wild/
git commit -m "Initialize Howl of the Wild publication manifest"
```
