# Converter Ownership and Upstream Refresh

This document explains the relationship between the upstream Foundry PF2e data converter, the automated refresh pipeline, and the human-curated content in OmenArchive.

## Overview

OmenArchive is the authoritative human-edited repository for Pathfinder 2e Remaster game content. While a significant portion of descriptive text originates from upstream data extracts (e.g. from `foundryvtt/pf2e`), mechanical logic, builder interactions, and Remaster alignments are curated directly in this repository.

When an automated refresh occurs, the converter reconciles incoming upstream updates against existing archive files. Understanding field ownership ensures that your manual contributions are preserved across automated refreshes.

## Field Ownership (`x-omen-ownership`)

Every property in our JSON schemas under `schemas/` declares an ownership model using the `x-omen-ownership` keyword:

| Ownership Value | Meaning | Examples |
| :--- | :--- | :--- |
| `"generated"` | Owned by the converter. Overwritten by refreshes when upstream text changes. | `description`, `foundryID`, `publication`, `traits`, `action`, `heightening` |
| `"archive"` | Owned by OmenArchive. **Never** overwritten by automated refreshes. | `rules`, `mechanicsScope`, `unsupportedReason`, `curriculum` |

### Rules and Mechanics Preservation

- **Reviewed Rules**: When a human author adds or customizes a `rules:` block, the converter tracks this as human-reviewed. Subsequent refreshes will **never** silently overwrite reviewed rules.
- **Divergence Detection**: If an upstream release introduces changes to an existing record, the refresh pipeline checks whether the human-reviewed mechanics still apply or flags the record for manual review.
- **Mechanics Scope**: The fields `mechanicsScope` and `unsupportedReason` belong entirely to the archive to document implementation limits.

## Hand-Authored Records

Certain records exist solely in OmenArchive and have no direct Foundry counterpart:
- Composite features generated for clean builder progression (e.g., class skill advancement tables).
- Errata corrections and Remaster bridging records.
- Records created by community contributors before upstream packs include them.

The refresh pipeline respects these records: if a file has no corresponding upstream source ID, it is preserved intact and counted as an archive-owned record.

## Reporting Upstream Data Errors vs. Archive Fixes

Before submitting a pull request, determine whether the change belongs in OmenArchive or in the upstream converter:

1. **Typo or Text Error in an Existing Description**:
   - If the error is present in the published Paizo book, it is often intentional or errata.
   - If the error is an artifact of upstream extraction, filing an issue or PR here is welcome; maintainers will ensure the fix is marked as human-reviewed or patched upstream.
2. **Missing Rule or Interactive Choice**:
   - Always authored directly in OmenArchive! Add or update the `rules:` block in the relevant YAML file.
3. **Structured System Fields (e.g., Hit Points, Speeds, Actions)**:
   - Check if the upstream source matches the printed Remaster book. If upstream is outdated, update the file and report the issue.

## Corpus Manifests and Migrations

The `docs/` directory contains critical metadata artifacts that track upstream provenance and historic path migrations:
- **`docs/player-core-corpus-manifest.json`**: An accounting manifest tracking every record in *Pathfinder Player Core* against the pinned upstream revision.
- **`docs/player-core-2-corpus-manifest.json`**: An accounting manifest for *Pathfinder Player Core 2*.
- **`docs/migrations/`**: Historical path maps (e.g. `docs/migrations/player-core-0055-v1.0.0.json`) used by consumers to preserve stable identity when records are moved or restructured between archive versions. These historical migration maps are frozen and must not be altered.
