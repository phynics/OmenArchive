# Archive Format and Repository Layout

This document describes the repository layout, publication structures, manifest contracts, and general file conventions of OmenArchive.

## Epoch and Format Version

OmenArchive adheres to the format declared in [`schemas/archive-format.json`](../../schemas/archive-format.json):
- **`epoch`**: `2`
- **`version`**: `2`

Every reader and validator requires exactly this pair. Breaking wire changes increment `version` within an epoch, while structural breaks with earlier data begin a new `epoch`.

## Repository Layout

```text
OmenArchive/
├── collections/                  # Multi-publication core collections
│   └── pathfinder-core.yml
├── docs/                         # Guides, references, and migrations
│   ├── how-to/                   # Step-by-step contribution guides
│   ├── reference/                # Detailed syntax and layout specifications
│   ├── mechanics.docc/           # Native DocC mechanics catalog
│   ├── converter-ownership.md    # Upstream refresh and field ownership
│   ├── glossary.md               # Definitions of domain terms
│   └── troubleshooting.md        # Common validation errors and remedies
├── mechanics/                    # Mechanics module JSON descriptors
│   ├── me.atkn.omen.pf2e.playercore.json
│   └── me.atkn.omen.pf2e.playercore-spellcasting.json
├── schemas/                      # JSON Schema definitions (Draft 2020-12)
│   ├── archive-format.json
│   ├── character-*.schema.json
│   └── utility-types/
├── scripts/                      # Local and CI validation scripts
│   ├── check-schemas.mjs
│   ├── check-links.sh
│   └── validate.sh
└── src/                          # Authored publication records
    ├── paizo-pathfinder-player-core/
    │   ├── publication.yml
    │   ├── action/
    │   ├── ancestry/
    │   ├── archetype/
    │   ├── background/
    │   ├── class/
    │   ├── companion/
    │   ├── condition/
    │   ├── domain/
    │   ├── feat/
    │   ├── item/
    │   ├── spell/
    │   └── versatile-heritage/
    └── paizo-pathfinder-player-core-2/
        └── ...
```

## Publication Manifests

Each publication folder in `src/{publication}/` must contain a `publication.yml` matching [`schemas/publication.schema.json`](../../schemas/publication.schema.json).

```yaml
id: paizo-pathfinder-player-core
publisher: Paizo
title: Pathfinder Player Core
code: "21-01"
isbn: "978-1-64078-564-9"
releaseDate: "2023-11-15"
license: ORC
mechanicsModules:
  core: me.atkn.omen.pf2e.playercore
  spellcasting: me.atkn.omen.pf2e.playercore-spellcasting
externalRecords:
  - omen://action/escape?source=paizo-pathfinder-player-core
```

- **`id`**: Must match the publication directory name and the canonical publisher/title slug.
- **`mechanicsModules`**: Maps short module aliases (`core`, `spellcasting`) used in `rules:` blocks to registered mechanics module IDs.
- **`externalRecords`**: Declares fully qualified references (`omen://...`) to records from publications not yet imported into the archive that are referenced by this publication.

## Resource Families: Flat vs. Bundle Layouts

The archive classifies records into 13 distinct families:

| Family | Layout | Path Pattern | Schema |
| :--- | :--- | :--- | :--- |
| `action` | Flat | `src/{pub}/action/{slug}.yml` | `character-action.schema.json` |
| `spell` | Flat | `src/{pub}/spell/{slug}.yml` | `character-spell.schema.json` |
| `item` | Flat | `src/{pub}/item/{slug}.yml` | `character-item.schema.json` |
| `background` | Flat | `src/{pub}/background/{slug}.yml` | `character-background.schema.json` |
| `feat` | Flat | `src/{pub}/feat/{slug}.yml` | `character-feat.schema.json` |
| `domain` | Flat | `src/{pub}/domain/{slug}.yml` | `character-domain.schema.json` |
| `companion` | Flat | `src/{pub}/companion/{slug}.yml` | `character-companion.schema.json` |
| `condition` | Flat | `src/{pub}/condition/{slug}.yml` | `character-condition.schema.json` |
| `versatile-heritage` | Flat | `src/{pub}/versatile-heritage/{slug}.yml` | `character-heritage.schema.json` |
| `ancestry` | Bundle | `src/{pub}/ancestry/{name}/{name}.yml`<br>`src/{pub}/ancestry/{name}/features/{slug}.yml`<br>`src/{pub}/ancestry/{name}/heritages/{slug}.yml` | `character-ancestry.schema.json`<br>`character-feature.schema.json`<br>`character-heritage.schema.json` |
| `class` | Bundle | `src/{pub}/class/{name}/{name}.yml`<br>`src/{pub}/class/{name}/features/{slug}.yml`<br>`src/{pub}/class/{name}/{group}/{slug}.yml` | `character-class.schema.json`<br>`character-feature.schema.json`<br>`character-feature.schema.json` |
| `archetype` | Bundle | `src/{pub}/archetype/{name}/{name}.yml`<br>`src/{pub}/archetype/{name}/feats/{slug}.yml` | `character-archetype.schema.json`<br>`character-feat.schema.json` |

### Custom Groups for Classes

Classes define specific sub-collections declared in `schemas/archive-format.json`. These files use the `character-feature` schema:
- Bard: `muses/`
- Cleric: `doctrine-features/`, `deities/`
- Druid: `orders/`
- Rogue: `rackets/`
- Sorcerer: `bloodlines/`
- Witch: `patrons/`, `basic-lessons/`, `greater-lessons/`, `major-lessons/`
- Wizard: `schools/`, `theses/`

## Collections

Collections live under `collections/*.yml` and conform to [`schemas/collection.schema.json`](../../schemas/collection.schema.json). They group publications into curated bundles (such as `pathfinder-core`):

```yaml
id: pathfinder-core
name: Pathfinder Core
publications:
  - paizo-pathfinder-player-core
  - paizo-pathfinder-player-core-2
```

## Equipment Taxonomy

Items are categorized into one of five top-level groups declared in the item schema:
- `weapon`
- `armor`
- `shield`
- `gear` (adventuring gear, alchemical items, tools, consumables)
- `treasure`

Each group has structured attributes defined in [`schemas/character-item.schema.json`](../../schemas/character-item.schema.json).

## General Authoring Conventions

- **Encoding**: All YAML files must be encoded in UTF-8 without byte order marks (BOM).
- **Naming**: Filename slugs use lowercase kebab-case (`reactive-strike.yml`).
- **One Record per File**: Exactly one resource per YAML document. Multi-document YAML streams (`---`) are disallowed.
- **No Raw Importer Bloat**: Never commit raw Foundry JSON, system flags, or temporary staging artifacts into the archive.
- **Stable Slugs**: Slugs are derived from the canonical English name of the game element. Do not prefix filenames with levels (write `reactive-strike.yml`, not `01-reactive-strike.yml`).
