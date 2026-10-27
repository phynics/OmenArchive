# Consuming the Archive

OmenArchive is designed to serve both as an authoring repository and as an open, structured database for third-party tools, character builders, virtual tabletops (VTTs), and reference websites.

This guide explains the archive's versioning promise, data architecture, identity model, and how to consume the data in other environments (such as Python, Node.js, and SQLite) without needing Swift.

---

## 1. Distribution Formats

OmenArchive provides three primary ways to access the data:

| Format | Access | Description | Best For |
| :--- | :--- | :--- | :--- |
| **Authored YAML** | Git clone (`src/`) | Compact, human-authored YAML files validated by JSON Schema. | Contributors, git-based workflows, diffing. |
| **Release JSONL** | GitHub Release asset (`omen-archive.jsonl.gz`) | Decoded wire form, one complete JSON object per line. | Streaming pipelines, search indexing, document databases. |
| **Release SQLite** | GitHub Release asset (`omen-archive.sqlite.gz`) | Single SQLite database with metadata, indexes, and views per family. | Desktop apps, local relational queries, Python/Node scripts. |

You can also generate the wire exports locally using the `omen-archive` CLI tool:

```bash
omen-archive wire path/to/OmenArchive export-dir \
  --jsonl export-dir/omen-archive.jsonl \
  --sqlite export-dir/omen-archive.sqlite
```

---

## 2. Versioning Promise

The format and structural contract of the archive are governed by `schemas/archive-format.json`.

```json
{
  "epoch": 2,
  "version": 2
}
```

* **`epoch`:** A major paradigm milestone. An epoch change indicates a fundamental shift in layout conventions or directory structures.
* **`version`:** The current format version within the epoch. Increments when a breaking schema change or layout modification is introduced.
* **Backward-compatible additions:** Adding optional fields to schemas, introducing new mechanics effects, or adding new content families do not increment the version.
* **Contract stability:** Any change to schema structures, required fields, or identifier semantics is documented in migration notes and gated across the test suite before release.

---

## 3. Publications and Families

The archive is organized into two primary hierarchical concepts: **publications** and **families**.

### Publications (`src/<publication-id>/`)

Each top-level directory under `src/` represents a published book or source. Every publication has a `publication.yml` manifest declaring:
* `id`: Unique publication slug (e.g. `paizo-pathfinder-player-core`, `paizo-pathfinder-player-core-2`).
* `title`: Human-readable book title.
* `publisher`: Publishing entity (e.g. `Paizo`).
* `published`: Release date (ISO 8601 calendar date).
* `mechanicsModules`: Modules and aliases used for rules in this publication.

### Families (`src/<publication-id>/<family>/`)

Families represent discrete categories of game concepts. The 13 core families are:

* `action`
* `ancestry`
* `archetype`
* `background`
* `class`
* `companion`
* `condition`
* `domain`
* `feat`
* `feature`
* `heritage`
* `item`
* `spell`

Some families use nested directories (custom groups or bundles). For example, class features and options live in subdirectories under the owning class (`src/<pub>/class/<class>/...`).

---

## 4. Identities and Reference Resolution

Every record in the archive has a canonical URI formatted according to the [OmenPath](reference/identities-and-references.md) specification:

```text
omen://<family>/<resource-path>?source=<publication-id>
```

### Examples

* **Feat:** `omen://feat/fleet?source=paizo-pathfinder-player-core`
* **Spell:** `omen://spell/fireball?source=paizo-pathfinder-player-core`
* **Nested Feature:** `omen://archetype/bard/feats/bard-dedication?source=paizo-pathfinder-player-core`
* **Publication:** `omen://publication/paizo-pathfinder-player-core`

### Resolving References

When records cross-reference other records:
* **Fully-qualified URIs:** Unambiguously identify the target and its source publication (e.g. `omen://condition/frightened?source=paizo-pathfinder-player-core`).
* **Relative slugs:** Inside an authored file, a bare slug (e.g. `fleet`) refers to the same family within the current publication. In the decoded wire format (JSONL and SQLite), references are fully resolved.

For full identity details, see [Identities and References](reference/identities-and-references.md).

---

## 5. Descriptive vs. Engine-Owned Fields

Records contain two categories of information:

### Descriptive Fields (Presentation & Game Rules)

These fields represent standard tabletop RPG text and parameters intended for display, search, and manual reference:
* `name`, `description`, `traits`, `source`
* `level` (feats, items, ancestries), `rank` (spells)
* `requirements`, `trigger`, `cost`, `prerequisites`
* Outcome descriptions (`success`, `criticalSuccess`, `failure`, `criticalFailure`)

### Engine-Owned Fields (`rules`)

The `rules` array contains structured, machine-executable declarations for rules engines and character builders (such as bonuses, granted feats, choices, and state toggles).

```yaml
rules:
  - key: speed-bonus
    effect: core/bonus
    target: speed
    value: 5
    type: status
```

### What the Archive Does Not Cover

* **Evaluation Engine:** The archive provides data definitions and authoring-level mechanics contracts. It deliberately does not publish a proprietary rules engine.
* **Runtime Dispatch:** Calculation order, bonus stacking rules (e.g. largest status bonus applies), and trigger condition dispatch must be evaluated according to the Pathfinder 2e Remaster rules by your own engine or application.

For detailed documentation on all available mechanics effects and their inputs, see the [DocC Mechanics Catalog](https://phynics.github.io/OmenArchive/documentation/index) (or browse source in [mechanics.docc](mechanics.docc)) or [Rules and Inputs](reference/rules-and-inputs.md).

---

## 6. Querying via SQLite

The SQLite release asset (`omen-archive.sqlite`) contains a pre-built relational database with SQLite JSON functions enabled.

### Database Schema

* **`archive_metadata` (`key TEXT PRIMARY KEY, value TEXT NOT NULL`):** Archive metadata (`epoch`, `version`, `record_count`, `exported_at`).
* **`records` (`uri TEXT PRIMARY KEY, publication TEXT, family TEXT, slug TEXT, name TEXT, path TEXT, data JSON`):** All records in the archive.
* **Views per family:** `actions`, `ancestries`, `archetypes`, `backgrounds`, `classes`, `companions`, `conditions`, `domains`, `feats`, `features`, `heritages`, `items`, `spells`.

### CLI Example

```bash
# Get archive version and count
sqlite3 omen-archive.sqlite "SELECT * FROM archive_metadata;"

# Find all 3rd-rank fire spells
sqlite3 omen-archive.sqlite "
  SELECT name, json_extract(data, '$.rank') AS rank
  FROM spells
  WHERE json_extract(data, '$.rank') = 3
    AND json_extract(data, '$.traits') LIKE '%fire%'
  ORDER BY name;
"
```

### Python Example

```python
import sqlite3
import json

conn = sqlite3.connect("omen-archive.sqlite")
cursor = conn.cursor()

# Query feats by level with structured JSON extraction
cursor.execute("""
    SELECT uri, name, data
    FROM feats
    WHERE publication = ? AND json_extract(data, '$.level') = 1
    ORDER BY name
""", ("paizo-pathfinder-player-core",))

for uri, name, raw_data in cursor.fetchall():
    feat = json.loads(raw_data)
    traits = ", ".join(feat.get("traits", []))
    print(f"{feat['name'].title()} [{traits}] - {uri}")

conn.close()
```

### Node.js Example

```javascript
import Database from 'better-sqlite3';

const db = new Database('omen-archive.sqlite');

const stmt = db.prepare(`
  SELECT uri, name, data
  FROM spells
  WHERE json_extract(data, '$.rank') = ?
`);

const spells = stmt.all(9);
for (const spell of spells) {
  const data = JSON.parse(spell.data);
  console.log(`${data.name} (Rank ${data.rank}) -> ${spell.uri}`);
}
```

---

## 7. Querying via JSONL

The JSONL release asset (`omen-archive.jsonl`) contains one record per line formatted as:

```json
{
  "uri": "omen://feat/fleet?source=paizo-pathfinder-player-core",
  "publication": "paizo-pathfinder-player-core",
  "family": "feat",
  "slug": "fleet",
  "name": "fleet",
  "path": "src/paizo-pathfinder-player-core/feat/fleet.yml",
  "data": { ... }
}
```

### Python Streaming Example

```python
import json
import gzip

# Stream directly without loading the whole dataset into memory
with gzip.open("omen-archive.jsonl.gz", "rt", encoding="utf-8") as f:
    for line in f:
        record = json.loads(line)
        if record["family"] == "condition":
            print(f"Condition: {record['name']} -> {record['uri']}")
```

---

## 8. Licensing and Attribution Obligations

When redistributing or using data from OmenArchive in third-party software:

1. **Schemas and Tooling:** The schemas, scripts, and format definitions are licensed under the **MIT License**.
2. **Game Content:** All Pathfinder Second Edition Remaster rules text, descriptions, names, and statistics are published under the **Open RPG Creative (ORC) License**.
3. **Attribution:** If your product or tool uses this content, you must include the ORC Notice and the attribution citations specified in [NOTICE](../NOTICE) and [LICENSE.md](../LICENSE.md).
