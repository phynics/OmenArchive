# OmenArchiveKit

`OmenArchiveKit` is the Swift interpretation module for the OmenArchive format.
Its first slice loads `OmenArchive/schemas/archive-format.json` and classifies an
archive-relative path into a publication manifest or a declared resource family,
layout, and schema. It also enumerates authored YAML in stable order and reads
only regular UTF-8 files, rejecting hidden entries and symlinks.

Bundle custom groups are owner-scoped declarations in the archive manifest. A
declared group such as `class/bard/muses` selects its schema through the same
classification interface as standard children. Undeclared bundle children are
rejected. Archetypes use the same bundle contract with `feats` children.
Domains and companions are flat top-level families.

The package is deliberately independent of OmenTome, SwiftData, and SwiftUI. It
depends only on shared mechanics and URI products plus Yams for YAML decoding.
Schema validation, mechanics validation, and deterministic traversal run through
this package locally and on Linux CI. Ruby remains in CI only for corpus- and
import-specific data assertions.

Run the package contract tests with:

```sh
swift test
```

The suite also runs complete integration validation against the containing
OmenArchive repository.

The executable adapter accepts an archive root and a relative path:

```sh
swift run omen-archive classify .. src/paizo-pathfinder-player-core/spell/fireball.yml
swift run omen-archive validate-layout ..
swift run omen-archive validate ..
```
