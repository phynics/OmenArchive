# Spellcasting Tables and Sources

This document describes the authoring shorthand for spellcasting progression, spell slots, curricula, repertoires, and spellbooks.

## The `spellcasting:` Shorthand Block

A spellcasting class feature defines its progression concisely using a `spellcasting:` block. At compile time, the reader expands this block into explicit rules (`configure-source`, `increase-source-proficiency`, `grant-slot`, and `add-known-spell` by level).

```yaml
spellcasting:
  source: { kind: prepared, tradition: arcane, attribute: int }
  slots:                       # Cumulative counts: cantrips, then ranks 1-10
    1: [5, 2]
    2: [5, 3]
    3: [5, 3, 2]               # Omitted levels repeat the previous row
  spellbook:                   # Repertoire or spellbook progression
    1: { cantrips: 10, rank-1: 5 }
    2-20: { any-rank: 2 }      # Or { new-slots: true }
```

### Cumulative Slot Rows

The `slots:` mapping specifies the cumulative spell slots per rank, matching printed book tables:
- The first element is the number of prepared cantrips.
- Subsequent elements correspond to spell ranks 1 through 10.
- Levels with identical slot counts can be omitted; the engine repeats the prior row.
- Slot counts may never decrease from one level to the next.

## Source Linkage and Curricula

When a subclass or archetype adds to an existing spellcasting feature, it references that source rather than redefining it:

```yaml
spellcasting:
  source: '@class.wizard.features.wizard-spellcasting'
  spellbook:
    from: curriculum
```

A wizard school providing curriculum spells declares its slots and spells in a `curriculum:` block on the school feature record.

## Witch Patrons and Traditions

A witch's spellcasting source tradition depends on their patron:
- The baseline Witch Spellcasting feature declares `source: patron`.
- Each patron option configures the source tradition (`arcane`, `divine`, `occult`, or `primal`).
- The spellbook progression offers spells matching that patron's tradition.

## Innate Spells vs. Spellcasting Sources

- **Innate Spells**: Handled as inline rules using `spellcasting/grant-innate-spell` or `grant-focus-spell`. Do not model innate spells as class spellcasting slots.
- **Cantrips**: Innate cantrips use `rankPolicy: { kind: cantrip }` and `castFrequency: { kind: atWill }`.
- **Daily Innate Spells**: Use `{ kind: fixed, rank: N }` and `{ kind: perDay, uses: N }`.
