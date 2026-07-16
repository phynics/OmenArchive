# 03 — Support multi-choice selection policies and default restrictions

**Repository:** `OmenCore`
**Priority:** Foundation
**Depends on:** 02
**Blocks:** 05, 07, 08

## Goal

Support selections with an exact `count`, including choices such as “select two fighter feats”. By default, candidates must meet their requirements, cannot already be owned, and cannot be picked twice. The author format exposes exceptions explicitly.

## Required policy

```yaml
choose:
  name: fighter_feats
  count: 2
  from: ...
  allow:
    unmet_requirements: true
    already_owned: true
    duplicates: true
```

All three `allow` values default to `false` and are independent.

## Scope

- Extend encoded selections and reconciliation to retain multiple selections per defined choice.
- Evaluate candidate resource requirements by default.
- Exclude resources already owned by the character by default.
- Reject selecting the same resource twice within one choice by default.
- Preserve stable selection identity across refreshes using the rule identity and choice name.

## Likely files

- `Sources/OmenCore/Selections/EncodedSelection.swift`
- `Sources/OmenCore/Selections/EncodedSelectionOptions.swift`
- `Sources/OmenCore/Selections/SelectionReconciler.swift`
- `Sources/OmenCore/CharacterBuilder/RulesEngine/CharacterEffect+Application.swift`
- `Sources/OmenCore/Models/Records/FeatRepeatPolicy.swift`
- `Tests/OmenCoreTests/LookupSelectionPersistenceTests.swift`
- `Tests/OmenCoreTests/RepeatableFeatIntegrationTests.swift`

## Acceptance criteria

- A count-two resource choice stores two distinct values and rehydrates them after a character rebuild.
- A duplicate pick, an already-owned pick, and an unmet-prerequisite pick are each rejected by default with an actionable diagnostic.
- Enabling one `allow` exception changes only that corresponding restriction.
- Existing single-value selections remain compatible at the runtime API level.
- Selection ordering and repeatable-feat behavior remain deterministic.

## Verification

```bash
swift test --package-path OmenCore --filter LookupSelectionPersistenceTests
swift test --package-path OmenCore --filter RepeatableFeatIntegrationTests
swift test --package-path OmenCore
```
