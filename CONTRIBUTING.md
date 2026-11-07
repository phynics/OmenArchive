# Contributing to OmenArchive

Thank you for helping curate and maintain OmenArchive! This repository is the open source, human-edited source of truth for Pathfinder 2e Remaster rules data.

---

## Code of Conduct & Licensing

### Licensing Rules

1. **Open RPG Creative (ORC) License Only**:
   - All game content contributed to OmenArchive must be licensed under the **ORC License** (or compatible open game licenses as specified in the publication manifest).
   - **Strictly No OGL Content**: Content from the Open Game License (OGL 1.0a) or pre-Remaster material is not accepted.
   - **No Proprietary or Unreleased Content**: Do not submit proprietary setting lore, adventure story text, or unreleased material.
2. **No Raw Foundry Bloat**:
   - Never paste raw Foundry JSON, system flags, or temporary conversion artifacts into archive files.
3. **Schemas & Code**:
   - The schemas and validation scripts in this repository are licensed under the MIT License.

---

## Getting Started

### 1. Fork and Clone

```bash
git clone https://github.com/<your-username>/OmenArchive.git
cd OmenArchive
```

### 2. Editor Setup

We recommend Visual Studio Code with the Red Hat YAML extension (`redhat.vscode-yaml`). The repository includes `.vscode/settings.json`, which automatically maps all YAML files across the 13 resource families to their corresponding JSON schemas under `schemas/`.

### 3. Optional Pre-Commit Hook

Install the local pre-commit hook to automatically validate changed files before committing:

```bash
./scripts/install-pre-commit.sh
```

---

## Validation Tiers

We use a two-tiered validation model to support contributors on any platform:

### Tier 1: Standalone Schema Check

A lightweight Node.js validator that verifies structural YAML syntax and schema compliance without requiring a Swift toolchain.

Install dependencies (once):
```bash
npm install --no-save ajv@^8.17.1 ajv-formats@^3.0.1 yaml@^2.7.0
```

Run on the entire archive:
```bash
npm run check-schemas
# or
node scripts/check-schemas.mjs
```

Or validate a specific file:
```bash
node scripts/check-schemas.mjs src/paizo-pathfinder-player-core/feat/fleet.yml
```

**What Tier 1 Checks:**
- Structural YAML syntax and valid UTF-8 encoding.
- Field types, required properties, enums, regex patterns, and value ranges against `schemas/*.schema.json`.
- Publication manifests and collections.

**What Tier 1 Does NOT Check:**
- Cross-file `@` reference resolution and inline `omen://` link targets.
- Mechanics effect input validation against compiled module descriptors.
- Deterministic UUID derivation and collision detection.

### Tier 2: Full Validation Gate (Local Toolchain)

The full reference validator is implemented in `OmenArchiveKit` (Swift 6.4 / macOS or Linux). It verifies all cross-record links, derived rule identities, and mechanics contracts.

Beyond the schemas, `omen-archive validate` checks, naming the record and the authored line:

| Check | What it reports |
|---|---|
| Sheet expressions | Malformed syntax, an unknown operator, a wrong argument count, a constant division by zero, a read nothing defines or that isn't a number, and a value of the wrong kind for its input (a condition where a number belongs) |
| `hasChoice` tests | A value the question can never hold, and a value of another type than the answer |
| Record references | A record-id input naming a record of another family (a feat input given a spell), and a list entry's record outside the list's declared collection |
| List items | A wrong item type and a missing entry field, also in the single-file check an editor runs on save |

Whole-archive analyses (dependency cycles, reachability, rule ordering, termination) run in the maintainers' tooling, not in `omen-archive`.

If you have `OmenArchiveKit` available:
```bash
./scripts/validate.sh
```

Maintainers run the full gate before they merge to `main`. No hosted CI runs on pull requests: run Tier 1 before you open one.

---

## Writing Rules for a Record

Describe a record's mechanics with what the format already has, in this order:

1. **Existing effects, questions, filters and expressions.** Most records need nothing else.
2. **Part of a rule can't be expressed:** write the part that can, and record the rest in
   `mechanicsScope` or `unsupportedReason`. A record that is partly applied is better than a new
   effect made for it alone.
3. **A new effect** is for something the engine must compute and no combination of the above can.
   Open an issue first that explains why, before writing records that need it. An effect never
   carries a rule's name from one book, display text, or a bonus or condition that belongs to a
   single record.

### Examples in the documents

Every ` ```yaml ` block in `docs/` and `USAGE.md` that is a whole record, a `rules:` block or a list
of rules is checked by the archive's tests: it must parse and validate as the format writes it. A
block that is only a fragment (two spellings side by side, fields of a manifest on their own) says so
on the line before its fence:

```markdown
<!-- docs-check: not a whole example — two spellings shown side by side -->
```yaml
distinct: {list: $.feats.assurance.skills}
distinct: [$.ancestry.name, {list: $.feats.assurance.skills}]
```
```

---

## Submitting Changes

### Step-by-Step Workflow

1. Create a feature branch:
   ```bash
   git checkout -b fix/trip-typo
   ```
2. Make your edits following the [How-To Guides](docs/how-to/) and [Reference Documentation](docs/reference/).
3. Validate your changes:
   ```bash
   npm run check-schemas
   bash scripts/check-links.sh
   ```
4. Commit with a clear, concise imperative message:
   ```bash
   git commit -m "Fix typo in Trip action description"
   ```
   > [!NOTE]
   > Do not include issue tracker numbers or private identifiers in commit messages.
5. Push to your fork and open a pull request using the provided PR template.

---

## What Reviewers Check

During PR review, maintainers verify:
- [ ] Schema validation passes cleanly.
- [ ] File and directory paths match declared conventions in `archive-format.json`.
- [ ] Record slugs are stable, lowercase kebab-case strings without level prefixes.
- [ ] No raw Foundry JSON or unsupported markup is present.
- [ ] Rules text matches published Remaster books under the ORC license.
- [ ] Hand-authored rules comply with [Converter Ownership](docs/converter-ownership.md).
