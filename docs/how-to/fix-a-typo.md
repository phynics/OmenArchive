# How-To: Fix a Typo or Descriptive Error

This guide walks you through fixing a typo, punctuation error, or descriptive text issue in an existing archive record.

## 1. Locate the File

Records are organized by publication and family under `src/{publication}/{family}/`. For example, to edit the description of the `Trip` action in *Player Core*:
`src/paizo-pathfinder-player-core/action/trip.yml`

## 2. Edit the Text

Open the file in your editor. Ensure your editor is configured to use UTF-8 without BOM and spaces (not tabs) for indentation.

```yaml
# Before:
description: |
  You trip an openent and they fall prone.

# After:
description: |
  You [Trip](omen://action/trip) an opponent and they fall [prone](omen://condition/prone).
```

### Prose Rules
- When linking to other records, use inline `omen://` links (`[Trip](omen://action/trip)`).
- Preserve standard Remaster terminology and casing in link labels.
- Do not add raw HTML or unescaped markdown punctuation.

## 3. Verify Your Change

Run the schema check on the modified file:
```bash
node scripts/check-schemas.mjs src/paizo-pathfinder-player-core/action/trip.yml
```

If you have OmenArchiveKit available locally, run the full validation:
```bash
./scripts/validate.sh
```

## 4. Commit and Submit

```bash
git add src/paizo-pathfinder-player-core/action/trip.yml
git commit -m "Fix typo in Trip action description"
```
Submit your pull request following the repository template.
