# 02 — Replace flat effect prerequisites with recursive requirements

**Repository:** `OmenCore`
**Priority:** Foundation
**Depends on:** 01
**Blocks:** 03, 05, 07, 08

## Goal

Replace the current implicit conjunction (`[ResourcePrerequisiteComponent]`) with a recursive requirement expression that supports `all`, `any`, `not`, and leaf predicates. The author DSL will use the same boolean structure for rule requirements and choice matching.

## Context

`CharacterEffect+Application.validatePrerequisites` currently uses `allSatisfy`. That cannot express “Strength 14 or Dexterity 14”, nested conditions, or negation. The archive format must support those cases without evaluating YAML itself in OmenBuilder.

## Scope

- Introduce a Codable, Hashable, Sendable `ResourceRequirement` AST.
- Use `.all([ResourceRequirement])`, `.any([ResourceRequirement])`, `.not(ResourceRequirement)`, and `.leaf(ResourcePrerequisiteComponent)`.
- Move `CharacterEffect` and any runtime resource prerequisite fields to the expression type.
- Implement recursive evaluation with diagnostics that identify the failing leaf or lookup-resolution error.
- Preserve empty requirements as satisfied.

## Non-goals

- Do not add new leaf predicate types beyond the current runtime capability in this ticket.
- Do not change the archive DTOs or YAML syntax here.

## Likely files

- Create `Sources/OmenCore/RecordResolver/ResourcePrerequisite/ResourceRequirement.swift`
- Modify `Sources/OmenCore/CharacterBuilder/RulesEngine/CharacterEffect.swift`
- Modify `Sources/OmenCore/CharacterBuilder/RulesEngine/CharacterEffect+Application.swift`
- Modify `Sources/OmenCore/Utility/ResourceTag.swift`
- Modify prerequisite Codable support
- Update `Tests/OmenCoreTests/CharacterBuilderTests.swift`
- Update `Tests/OmenCoreTests/CodableTests.swift`

## Acceptance criteria

- A nested `all(any(...), not(...))` condition evaluates correctly against a `CharacterSlice`.
- Evaluation short-circuits safely and records diagnostics when a leaf cannot be evaluated.
- Existing simple prerequisite behavior is equivalent to an `all` expression.
- Lookup-value, attribute, skill proficiency, class trait, feat, and feature leaves remain available.
- Runtime Codable data has deterministic encoding and tests cover nested values.

## Verification

```bash
swift test --package-path OmenCore --filter CharacterBuilderTests
swift test --package-path OmenCore --filter CodableTests
swift test --package-path OmenCore
```
