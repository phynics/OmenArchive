# OmenArchive

**OmenArchive** is an open-source, human-edited archive of Pathfinder 2e Remaster game data. It stores game content as structured, clean YAML files designed for version control, collaborative editing, and high-performance character builders and virtual tabletops.

---

## What Is in the Archive?

The archive contains comprehensive game records curated from official Paizo Remaster publications under the Open RPG Creative (ORC) License:

- **Publications**:
  - *Pathfinder Player Core* (`paizo-pathfinder-player-core`)
  - *Pathfinder Player Core 2* (`paizo-pathfinder-player-core-2`)
- **13 Resource Families**:
  - `action`: Basic, skill, and specialized combat actions.
  - `ancestry`: Character ancestries, physical traits, features, and heritages.
  - `archetype`: Multiclass and specialized archetypes and their dedication feats.
  - `background`: Character backgrounds with attribute boosts, trained skills, and feats.
  - `class`: Core classes, progressions, proficiencies, and subclass options.
  - `companion`: Animal companions and familiars.
  - `condition`: Game conditions and status effects.
  - `domain`: Cleric deity domains and associated domain spells.
  - `feat`: General, skill, ancestry, class, and archetype feats.
  - `item`: Weapons, armor, shields, adventuring gear, and alchemical items.
  - `spell`: Cantrips, ranked spells, focus spells, and rituals across all 4 traditions.
  - `versatile-heritage`: Lineage heritages selectable across any ancestry.
- **Curated Collections**:
  - Multi-publication groupings under `collections/` (such as `collections/pathfinder-core.yml`).

---

## Consuming the Archive

Building a character builder, virtual tabletop (VTT), or reference tool? OmenArchive releases attach pre-built, decoded distribution artifacts for third-party consumption:

- **Release SQLite Database (`omen-archive.sqlite.gz`)**: Full relational database with typed JSON extraction, indexes, and views per family.
- **Release JSONL Stream (`omen-archive.jsonl.gz`)**: One complete record per line, ideal for streaming ingest and search indexing.

See the [Consuming the Archive](docs/consuming-the-archive.md) guide for details on versioning promises, schema extraction, Python/Node.js examples, and SQL queries.

---

## Contributing to OmenArchive

We welcome community contributions! Most contributions fall into three categories:

1. **Typo and Descriptive Text Fixes**: Correcting typos, clarification notes, or Remaster wording adjustments. See [How-To: Fix a Typo](docs/how-to/fix-a-typo.md).
2. **Adding or Updating Records**: Adding a missing feat, spell, item, or action. See [How-To: Add a Feat](docs/how-to/add-a-feat.md) or [How-To: Add a Spell](docs/how-to/add-a-spell.md).
3. **Mechanics and Rule Interactions**: Authoring or refining interactive builder rules, attribute bonuses, or character choices. See [How-To: Add a Rule](docs/how-to/add-a-rule.md).

For step-by-step instructions on setting up your environment, running validation, and opening pull requests, please read [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Documentation Quick Links

| Guide | Description |
| :--- | :--- |
| [**Consuming the Archive**](docs/consuming-the-archive.md) | Guide for third parties using the archive as a database (JSONL, SQLite, Python, Node.js). |
| [**CONTRIBUTING.md**](CONTRIBUTING.md) | Contributor workflows, editor setup, licensing rules, and CI validation. |
| [**How-To Guides**](docs/how-to/) | Step-by-step guides for fixing typos, adding feats, spells, rules, and publications. |
| [**Reference Manual**](docs/reference/) | In-depth specifications for layout, `@` references, rules, filters, and families. |
| [**Converter Ownership**](docs/converter-ownership.md) | How automated upstream refreshes work and what fields the archive owns. |
| [**Mechanics Catalog**](https://phynics.github.io/OmenArchive/documentation/omenmechanics) | Native DocC catalog documenting all registered game engine effects and inputs (or browse source in [`docs/mechanics.docc/`](docs/mechanics.docc/)). |
| [**Glossary**](docs/glossary.md) | Definitions of archive terminology and data model concepts. |
| [**Troubleshooting**](docs/troubleshooting.md) | Common schema validation errors and how to resolve them. |
| [**Usage Index**](USAGE.md) | Comprehensive index of archive rules and conventions. |

---

## Quick Validation

You can validate YAML files locally using standard Node.js without compiling Swift:

```bash
# Validate the entire archive against schemas
npm run check-schemas

# Or check a specific file
node scripts/check-schemas.mjs src/paizo-pathfinder-player-core/feat/fleet.yml

# Verify documentation links
bash scripts/check-links.sh
```

---

## License

- Content derived from the Pathfinder Roleplaying Game is licensed under the [Open RPG Creative (ORC) License](https://azoralaw.com/orclicense/). See [NOTICE](NOTICE) and [LICENSE.md](LICENSE.md).
- Archive schemas, validation tools, and scripts are licensed under the [MIT License](LICENSE.md).
