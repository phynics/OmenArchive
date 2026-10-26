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

### Tier 1: Standalone Schema Check (Local & PR CI)

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

### Tier 2: Full Validation Gate (Maintainer CI & Local Toolchain)

The full reference validator is implemented in `OmenArchiveKit` (Swift 6.4 / macOS or Linux). It verifies all cross-record links, derived rule identities, and mechanics contracts.

If you have `OmenArchiveKit` available:
```bash
./scripts/validate.sh
```

The full gate runs automatically in trusted CI upon merge to `main`.

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
