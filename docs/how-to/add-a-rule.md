# How-To: Add a Rule to a Record

This guide explains how to add mechanical logic, stat bonuses, grants, or player choices to an existing record using the `rules:` array.

## 1. Identify the Desired Effect

Browse the native DocC catalog at [`docs/mechanics.docc/`](../mechanics.docc/) or inspect `mechanics/*.json` to find the registered effect that matches your mechanic.

Common effects include:
- `core/add-language`: Grants a known language.
- `core/add-sense`: Grants a sensory capability like darkvision or low-light vision.
- `core/add-speed-bonus`: Grants a speed bonus.
- `core/add-roll-modifier`: Applies a bonus/penalty to rolls, AC, or DCs.
- `core/add-feat`: Grants an additional feat (e.g. at a specific level).

## 2. Check the Effect's Inputs and Identity

Inspect the input parameters for your chosen effect.
- Bare literal inputs (e.g., `bonus: 5`, `kind: status`, `target: ac`) are specified directly under `inputs:`.
- Any input marked with `identity: rule` (such as `selectionId` or `grantId`) is automatically derived by the engine and **must be omitted** from your YAML.

## 3. Author the Rule

Add the `rules:` block to your file. Ensure you assign a unique, descriptive kebab-case `key`:

```yaml
rules:
  - key: darkvision-grant
    effect: core/add-sense
    inputs:
      sense: darkvision
```

### Adding a Choice Rule

To prompt the player for a decision, use a `choice:` block instead of `effect:`:

```yaml
rules:
  - key: choice-bonus-language
    choice:
      name: $.feat.multilingual.languages
      label: Bonus Language
      type: core/string
      freeText: core/string
```

Or a choice over archive records:

```yaml
rules:
  - key: choice-domain-spell
    choice:
      name: $.cleric.domain
      label: Domain Selection
      type: core/domain-id
      records:
        type: domain
        filter:
          all:
            - { type: domain }
```

## 4. Validate

```bash
node scripts/check-schemas.mjs src/path/to/file.yml
```

Full rules checking runs via:
```bash
./scripts/validate.sh
```

## 5. Commit

```bash
git add src/path/to/file.yml
git commit -m "Add darkvision grant rule to cavern elf heritage"
```
