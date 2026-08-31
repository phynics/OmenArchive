# Omen Tome
PF2RPG data archive with schemas

See [USAGE.md](USAGE.md) for repository conventions, resource layout, and OmenScribe workflow rules.

Validation:

- Run `./scripts/validate.sh` to validate the whole archive with the authoritative
  Swift validator in `OmenArchiveKit`.
- Run `swift test --package-path OmenArchiveKit` to exercise validator fixtures,
  mechanics contracts, and descriptor parity.
- Run `./scripts/install-pre-commit.sh` to install the repo-local pre-commit hook.

The archive layout contract is recorded in `schemas/archive-format.json`.
Owner-scoped bundle custom groups are declared there alongside their schemas.
Archetypes are bundles with owned `feats`; domains and companions are flat
families. `OmenArchiveKit` is the single schema and mechanics-validation
authority. Ruby tests remain for corpus-specific data assertions. The legacy
Ruby validator is retained temporarily as a recovery tool, but neither the
default validation command nor CI uses it as a semantic authority.
