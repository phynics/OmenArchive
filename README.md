# OmenArchive
PF2e resource archive with schemas

See [USAGE.md](USAGE.md) for repository conventions, resource layout, and OmenScribe workflow rules.

Validation:

- Run `./scripts/validate.sh` to validate the whole archive with the authoritative
  Swift validator, [OmenArchiveKit](https://github.com/phynics/OmenArchiveKit).
  The script resolves the Kit from `OMEN_ARCHIVE_KIT_ROOT` when set, otherwise
  from a checkout at `../OmenArchiveKit`.
- Run the Kit's own suite with `OMEN_ARCHIVE_ROOT=<this repo> swift test` in a
  Kit checkout to exercise validator fixtures, mechanics contracts, descriptor
  parity, and the schema/model parity gate.
- Run `./scripts/install-pre-commit.sh` to install the repo-local pre-commit hook.

The archive layout contract is recorded in `schemas/archive-format.json`.
Owner-scoped bundle custom groups are declared there alongside their schemas.
Archetypes are bundles with owned `feats`; domains and companions are flat
families. `OmenArchiveKit` is the single authoritative validation and test
suite for the repository schemas, mechanics, corpus, and import manifests.
