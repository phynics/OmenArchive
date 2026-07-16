# 05 — Implement the human resource and rule DSL in OmenTome

**Repository:** `OmenBuilder`
**Priority:** Core format
**Depends on:** 04
**Blocks:** 06, 07, 08

## Goal

Replace legacy YAML that mirrors OmenCore templates with concise human-authored documents. Resources use `snake_case`, presentation names, omitted defaults, and OmenPath references. Rules describe game intent rather than `effectTemplate`, recipes, typed literals, or UUIDs.

## Required rule model

- A rule has a locally unique `name`.
- Runtime rule UUID is derived from the qualified owner OmenPath plus rule name.
- Rule operations are closed, domain-directed variants: grants, proficiencies, roll modifiers, critical specialization, lookup entries, spellcasting entry/slot/proficiency, and placeholders.
- Values are literal, `choose`, or `lookup`.
- Fixed generated references are source-qualified OmenPaths.
- An unqualified exact OmenPath represents a logical resource version set, not a broad selection filter.
- Broad selection uses `from.type` plus a recursive `matching` expression.

## Required resource style

```yaml
name: Barrister
boosts:
  - choose: [intelligence, charisma]
  - free
trained: diplomacy
lore: legal
feat: omen://feat/group-impression?source=paizo-pathfinder-player-core
```

## Scope

- Replace camel-case archive DTO keys with closed snake-case DTOs.
- Omit defaults, empty arrays, empty strings, and internal placeholders when encoding.
- Implement `all`, `any`, and `not` expressions for rule requirements and candidate matching, with context-specific leaves.
- Implement choices, `count`, and the explicit `allow` exceptions.
- Reject the legacy generic rule representation entirely.

## Likely files

- `OmenTome/Sources/OmenTome/Character*.swift`
- Replace `OmenTome/Sources/OmenTome/CharacterRule.swift`
- Create `OmenTome/Sources/OmenTome/Archive/RequirementExpression.swift`
- Create `OmenTome/Sources/OmenTome/Archive/ChoiceExpression.swift`
- Update `OmenTome/Tests/OmenTomeTests/RulesCodingTests.swift`
- Create `OmenTome/Tests/OmenTomeTests/ArchiveFormatTests.swift`

## Acceptance criteria

- All supported resource families decode and encode in the approved style.
- Unknown keys are rejected.
- Rule fixtures cover fixed grants, dynamic choices, lookup consumption, count-two selections, exception flags, version choices, and nested requirements.
- No author-facing document contains UUID effect IDs, `effectTemplate`, `inputRecipes`, `startLevel`, typed literal wrappers, or a generic `kind` escape hatch.
- OmenPath diagnostics name the author field and explain cardinality/qualification errors.

## Verification

```bash
swift test --package-path OmenTome --filter RulesCodingTests
swift test --package-path OmenTome
```
