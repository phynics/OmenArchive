# Spellcasting Tables and Sources

This document describes the authoring shorthand for spellcasting progression, spell slots, curricula, repertoires, and spellbooks.

## The `spellcasting:` Shorthand Block

A spellcasting class feature defines its progression concisely using a `spellcasting:` block. At compile time, the reader expands this block into explicit rules (`configure-source`, `increase-spell-proficiency`, `grant-slot`, and `allow-known-spells` by level).

```yaml
spellcasting:
  source: { kind: prepared, tradition: arcane, attribute: intelligence }
  slots:                       # Cumulative counts: cantrips, then ranks 1-10
    1: [5, 2]
    2: [5, 3]
    3: [5, 3, 2]               # Omitted levels repeat the previous row
  spellbook:                   # Repertoire or spellbook progression
    1: { cantrips: 10, rank-1: 5 }
    2-20: { any-rank: 2 }      # Or { new-slots: true }
```

### Free Spell Picks

The `spellbook:` counts are the spells the player adds to the repertoire or spellbook for free. A pick is not a question. Each level's picks of one kind expand to one `allow-known-spells` rule that carries the count: the player makes the picks in the collection editor, and the rule grants no spell itself.

| Spellbook entry | Pick | Takes |
|---|---|---|
| `cantrips: 10` | `cantrip` | cantrips |
| `rank-1: 5` | `{rank: 1}` | spells of exactly that rank |
| `any-rank: 2` | `{upTo: N}` | spells of any rank up to `N`, the highest rank of slot the source has at that level |
| `new-slots: true` | `{rank: R}` for each rank that opens | one spell per new slot of that rank (the 10th-rank slot has its own count, `{rank-10: 2}`) |

The rule's `filter` holds what the spells must be: common spells of the source's tradition, or of the tradition of its patron (the witch). A school's curriculum picks come from exactly the spells it lists, uncommon ones included, so its filter is the list. A `choose:` list is one pick from exactly the listed spells, of any rank. The same rule outside a block is written like any other rule:

```yaml
- key: allow-known-spells-1
  effect: spellcasting/allow-known-spells
  level: 3
  inputs:
    source: wizard-spellcasting
    count: 2
    pick: {upTo: 2}
    filter:
      all:
      - {type: spell}
      - {spell.tradition: arcane}
      - {rarity: common}
```

A record has no choice named `$.spellbook.*`; the archive check refuses one.

### Cumulative Slot Rows

The `slots:` mapping specifies the cumulative spell slots per rank, matching printed book tables:
- The first element is the number of prepared cantrips.
- Subsequent elements correspond to spell ranks 1 through 10.
- Levels with identical slot counts can be omitted; the engine repeats the prior row.
- Slot counts may never decrease from one level to the next.

## Source Linkage and Curricula

When a subclass or archetype adds to an existing spellcasting feature, it names that source by its key rather than redefining it:

```yaml
spellcasting:
  source: wizard-spellcasting
  spellbook:
    from: curriculum
```

The block's `source` is one of three things: a map (`{kind, tradition, attribute}`) that defines the source, `patron` (the source belongs to a class whose patrons configure it), or the key of a source defined elsewhere.

## Source Keys

Every spellcasting source has a **key**: its name in kebab-case, as the book names it. `Wizard Spellcasting` is `wizard-spellcasting`, `Ranger Focus Spells` is `ranger-focus-spells`, `Hag Magic` is `hag-magic`. A rule names its source by the key, in the input `source`:

```yaml
- key: grant-warden-spell
  effect: spellcasting/grant-focus-spell
  inputs:
    source: ranger-focus-spells
    spellId: {choice: $.feat.masterful-warden.spell}
```

The publication declares each key once, in `spellcastingSources` of its `publication.yml`, with the ID the engine and the OmenDB store know the source by:

```yaml
spellcastingSources:
  ranger-focus-spells: ad075a6c-56ec-5561-ae46-5a8565022188
  wizard-spellcasting: c78cb906-1cd7-57cc-b713-288becbb7f90
```

- The ID is written here and nowhere else. A record never carries a literal source ID, and the reader refuses a source ID the publication doesn't declare.
- The key is also what a filter names: `{ knownBySource: wizard-spellcasting }`, `{ hasSourceTradition: witch-spellcasting }`. The wire form holds the ID in each place.
- A source is named the same way wherever it appears. The archive check refuses two source names that give one key (`Hag Magic` and `hag  magic`), a source whose key the publication doesn't declare or declares for another ID, and a record that names a key no source defines.
- A source a `spellcasting:` block defines is declared under the key of its feature's name (`wizard-spellcasting`) with the ID the block derives, so the check holds the two together.
- To add a source, choose its key, write a new lowercase UUID for it under `spellcastingSources`, and name the key in the rules.

A wizard school providing curriculum spells declares its slots and spells in a `curriculum:` block on the school feature record.

## Witch Patrons and Traditions

A witch's spellcasting source tradition depends on their patron:
- The baseline Witch Spellcasting feature declares `source: patron`.
- Each patron option configures the source tradition (`arcane`, `divine`, `occult`, or `primal`).
- The spellbook picks come from spells matching that patron's tradition.

## Innate Spells vs. Spellcasting Sources

- **Innate Spells**: Handled as inline rules using `spellcasting/grant-innate-spell` or `grant-focus-spell`. Do not model innate spells as class spellcasting slots.
- **Cantrips**: Innate cantrips use `rankPolicy: cantrip` and `castFrequency: atWill`.
- **Daily Innate Spells**: Use `rankPolicy: { fixed: N }` and `castFrequency: { perDay: N }`.

## Focus pool and spell proficiency

- **Focus pool**: derived, never written. A character has one focus point for each focus spell granted (`spellcasting/grant-focus-spell`, which is the only way to grant one), up to 3. A focus cantrip cast at will adds nothing. Domain spells are granted by reading the chosen domain's `domainSpell` or `advancedDomainSpell` field: `spellId: $.cleric.domains.domainSpell` (the short form of `{choice: $.cleric.domains, field: domainSpell}`).
- **Spell proficiency**: a character has one spell attack and spell DC rank, raised with `spellcasting/increase-spell-proficiency`; each source keeps its own key attribute. A character with an innate source is at least trained.
- **Known spells and the spell list**: `add-known-spell` adds a list of spells the feature names to the repertoire or spellbook; `allow-known-spells` lets the player pick a number of spells for it; `add-spell-list` adds spells to the source's spell list only. A feature that does both (the oracle's Divine Access) carries one rule of each.
