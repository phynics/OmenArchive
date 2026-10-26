# Using OmenArchive

OmenArchive is the human-edited source repository for Pathfinder 2e Remaster game data. It defines the schemas, stores curated game resources, and serves as the authoritative source of truth from which runtime stores (like OmenDB) and third-party databases are built.

---

## Reference Manual Hub

Detailed technical specifications are divided into focused topic guides:

| Guide | Description |
| :--- | :--- |
| [**Format and Repository Layout**](docs/reference/format-and-layout.md) | File trees, publication manifests (`publication.yml`), collections, and epoch/version rules. |
| [**Identities and References**](docs/reference/identities-and-references.md) | `@reference` syntax, canonical `omen://` URIs, member resolution, and prose links. |
| [**Rules and Inputs**](docs/reference/rules-and-inputs.md) | The `rules` array, choices (`$.` paths), effect invocations, and input typing. |
| [**Filters**](docs/reference/filters.md) | Filtering syntax for dynamic choices (`all`, `any`, traits, levels, and prerequisites). |
| [**Spellcasting Tables**](docs/reference/spellcasting.md) | Compact class spell tables (`spellcasting:` block), slot progression, and repertoires. |
| [**Family Conventions**](docs/reference/family-conventions.md) | Structural schemas, directory locations, and examples for all 13 content families. |
| [**Consuming the Archive**](docs/consuming-the-archive.md) | Guide for third parties using release JSONL streams and SQLite databases without Swift. |
| [**Converter Ownership**](docs/converter-ownership.md) | Field ownership during upstream refreshes (`"x-omen-ownership": "archive"`). |

---

## 13 Content Families Index

- **Actions**: `src/{pub}/action/{slug}.yml` — [Action Conventions](docs/reference/family-conventions.md#1-actions)
- **Spells**: `src/{pub}/spell/{slug}.yml` — [Spell Conventions](docs/reference/family-conventions.md#2-spells)
- **Ancestries**: `src/{pub}/ancestry/{ancestry}/{ancestry}.yml` — [Ancestry Conventions](docs/reference/family-conventions.md#3-ancestries)
- **Conditions**: `src/{pub}/condition/{slug}.yml` — [Condition Conventions](docs/reference/family-conventions.md#4-conditions)
- **Backgrounds**: `src/{pub}/background/{slug}.yml` — [Background Conventions](docs/reference/family-conventions.md#5-backgrounds)
- **Classes**: `src/{pub}/class/{class}/{class}.yml` — [Class Conventions](docs/reference/family-conventions.md#6-classes)
- **Feats**: `src/{pub}/feat/{slug}.yml` — [Feat Conventions](docs/reference/family-conventions.md#7-feats)
- **Heritages**: `src/{pub}/ancestry/{ancestry}/heritages/{slug}.yml` and `src/{pub}/versatile-heritage/{slug}.yml` — [Heritages in Family Conventions](docs/reference/family-conventions.md#8-heritages-and-versatile-heritages)
- **Archetypes**: `src/{pub}/archetype/{archetype}/{archetype}.yml` — [Archetype Conventions](docs/reference/family-conventions.md#9-archetypes)
- **Items**: `src/{pub}/item/{slug}.yml` — [Item Conventions](docs/reference/family-conventions.md#10-items-and-equipment)
- **Domains**: `src/{pub}/domain/{slug}.yml` — [Domain Conventions](docs/reference/family-conventions.md#11-domains)
- **Companions**: `src/{pub}/companion/{slug}.yml` — [Companion Conventions](docs/reference/family-conventions.md#12-companions)
- **Features**: `src/{pub}/class/{class}/features/{slug}.yml` — [Feature Conventions](docs/reference/family-conventions.md#13-features)

---

## Validation Checklist Before Rebuild

Run validation checks locally:

```bash
# Fast schema check without Swift
npm run check-schemas

# Check documentation links
bash scripts/check-links.sh
```

Before committing:
1. All authored YAML files are UTF-8 encoded.
2. File paths strictly match `{publication}/{family}/{slug}.yml` or the bundle conventions.
3. Every file validates against its JSON Schema under `schemas/`.
4. `@` references and `omen://` URI destinations resolve to valid targets.
5. No unreviewed Foundry rule element JSON exists in descriptive text fields.
