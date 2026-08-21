# Omen Tome
PF2RPG data archive with schemas

See [USAGE.md](USAGE.md) for repository conventions, resource layout, and OmenScribe workflow rules.

Validation:

- Run `./scripts/validate.sh` to validate the whole archive.
- Run `./scripts/validate-swift.sh` to use the sibling `OmenArchiveKit` validator
  when the package and its local `OmenCore` dependency are available on macOS;
  archive-only or non-macOS checkouts report a deliberate skip. Linux is not a
  verification gate for this migration.
- Run `./scripts/install-pre-commit.sh` to install the repo-local pre-commit hook.

The archive layout contract is recorded in `schemas/archive-format.json`. The
Swift `OmenArchiveKit` package is being introduced as the single executable
interpretation of that manifest; the Ruby validator remains a parity oracle
until OmenScribe adopts the package. Linux verification is intentionally
deferred.
