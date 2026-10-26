# OmenArchive Glossary

This glossary defines core concepts, terms, and data constructs used throughout OmenArchive.

### Ancestry
A character's biological, hereditary, or cultural origin (e.g. Elf, Dwarf, Human). Authored as a bundle containing the base ancestry record, features, and heritages.

### Archetype
A collection of thematic feats taken in place of class feats, gated by a dedication feat. Authored as a bundle containing an archetype root record and child feats.

### Archive Format
The structural contract declared in `schemas/archive-format.json` with an explicit `epoch` and `version` (currently `epoch: 2, version: 2`).

### Bare Literal
An input value written as a direct scalar or dictionary without dynamic evaluation markers (e.g. `proficiencyCap: 2`).

### Bundle
A multi-file directory representing a complex game element (such as an `ancestry`, `class`, or `archetype`) containing a root record and owned sub-directories for features, heritages, or feats.

### Choice (`choice:`)
A rule that presents an interactive prompt to the player in a character builder or sheet.

### Collection
A group of related publications defined in `collections/*.yml` (such as `pathfinder-core`).

### Derived Identity
A UUID or identifier deterministically derived by the engine from a record's path and rule key using UUIDv5. Authored YAML files omit derived identities.

### Descriptor
A JSON document in `mechanics/` that declares the signature, inputs, types, and writes of mechanics effects.

### Effect
A discrete game mechanic registered in a mechanics module (e.g. `core/add-roll-modifier`, `core/add-language`).

### Family
One of the 13 primary record categories in the archive (e.g. `action`, `spell`, `item`, `feat`, `class`).

### Flat Layout
A directory containing single, self-contained record files for a resource family (e.g. `src/{pub}/feat/{slug}.yml`).

### OmenPath
The canonical URI identifying a record across the archive: `omen://{family}/{path}?source={publication-id}`.

### Publication
A published source book or document with an identifier, metadata manifest (`publication.yml`), and content directories under `src/{publication-id}/`.

### Record
A single YAML file defining one game element conforming to a family schema.

### Rule
An entry in a record's `rules:` array specifying a mechanic, grant, or choice.

### Shorthand Reference (`@`)
A compact cross-record pointer used in structured YAML fields (e.g. `'@feat.reactive-strike'`).

### Slug
The lowercase kebab-case filesystem identifier for a record or directory (e.g. `nimble-dodge`).
