# Omen Archive Format Tickets

These local tickets implement the approved Omen Archive format redesign. They are deliberately ordered by dependency; do not begin a ticket until its listed prerequisites have landed.

| Order | Ticket | Repository | Depends on |
| --- | --- | --- | --- |
| 1 | [Publication-aware OmenPath resolution](01-omen-core-publication-aware-omenpath-resolution.md) | OmenCore | — |
| 2 | [Recursive requirements](02-omen-core-recursive-requirements.md) | OmenCore | 01 |
| 3 | [Multi-choice selection policies](03-omen-core-multi-choice-selection-policies.md) | OmenCore | 02 |
| 4 | [OmenTome archive module](04-omen-builder-omentome-archive-module.md) | OmenBuilder | 01 semantics |
| 5 | [Human resource and rule DSL](05-omen-builder-human-resource-and-rule-dsl.md) | OmenBuilder | 04 |
| 6 | [Formatter, schemas, and CLI](06-omen-builder-archive-cli-and-schemas.md) | OmenBuilder | 05 |
| 7 | [OmenBuilder import/export integration](07-omen-builder-import-export-integration.md) | OmenBuilder | 01–06 |
| 8 | [Archive migration and legacy removal](08-omen-archive-migration-and-legacy-removal.md) | OmenArchive | 06, coordinated with 07 |
| 9 | [Pinned CI compatibility](09-cross-repo-ci-and-release-compatibility.md) | OmenArchive + OmenBuilder | 01–08 |

The complete rationale, approved syntax, and dependency graph are in [the implementation plan](../../superpowers/plans/2026-07-16-omen-archive-format.md).
