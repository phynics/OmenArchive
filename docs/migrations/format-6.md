# Moving From Format 5 to Format 6

This note is for a person or a tool that reads archive format 5 and must read format 6. It lists what
changed, construct by construct. The reference pages describe the current format; this page says what
a format 5 reader must change.

## What Format 6 Is

Format 6 is one version bump. `schemas/archive-format.json` now says `epoch: 2` and `version: 6`. The
epoch does not change, so the layout rules and the identity model stay as they were. A reader
requires the exact pair, so a format 5 reader refuses a format 6 archive, and a format 6 reader refuses
a format 5 archive.

Three kinds of change make the bump:

- **Removals.** Constructs that a second spelling or no record used are gone, and a format 6 reader
  refuses them.
- **New spellings.** Some rules, ranks, links and facts are written in a new form. The archive holds
  the new form only.
- **Closed schemas.** Every object in a record is closed. A new field in a schema raises the version
  from now on.

The decoded wire form (`omen-archive wire`, the JSONL and SQLite streams) keeps the fully expanded
form. A reader of the wire form has less to change than a reader of the authored YAML. Where the wire
form differs, this note says so.

## What a Format 5 Reader Must Change

### Removed and Replaced Effects

A format 6 archive has no record that uses these effects, and a format 6 reader refuses a record
that uses one.

| Format 5 | Format 6 |
|---|---|
| `extend-class-key-attribute` | `add-to-list` on `$.class.key-attribute-options`, with the attribute as the value |
| `substitute-skill` | `add-to-list` on `$.skills.substitutions`, with an entry of `skill` and `substitute`, and an `add-note` rule beside it that says what the substitution does |
| `add-formulas` | A rule with `forEach` over the list of the question it read, which adds `{item: true}` to `$.crafting.formulas` |
| `add-heritage` | `add-feature@2`, which takes a heritage |
| `add-terrain-expertise` | A rule with `forEach` over the list the question adds to, with an `add-modifier@2` for each terrain |
| `add-specialty-crafting` | An `add-modifier@2` rule: +1, and +2 for a master in Crafting, to crafting items of the chosen specialty |
| `add-weapon-critical-specialization` | An `add-note` rule on attack rolls, with the condition the record states (five records changed) |
| `add-modifier` (revision 1) | `add-modifier@2`: `amount` is a number or an expression |
| `add-saving-throw` with `savingThrow: perception` | `add-perception` with the same `rank` |

Perception is a statistic of its own:

- A class writes `perceptionProficiency` beside a `savingThrowProficiency` of the three saves. The
  saving-throw schema no longer lists `perception`.
- A prerequisite `hasSavingThrowProficiency: {savingThrow: perception, rank: expert}` is
  `hasPerceptionProficiency: expert`.
- In a written-out roll description, `anySavingThrow` is the three saves and replaces
  `anyNonPerceptionSavingThrow`. The words for a roll target (`saving-throws`, `perception`) do not
  change.

A record that had a pair of `add-modifier` rules for one situation (a flat bonus, and a larger one
while a condition holds) now has one rule. Its `amount` adds the condition to the flat bonus.

### Removed Prerequisite Kinds, Value Types and Spellings

- **Prerequisite kinds.** `hasClassTrait`, `hasLevel`, `hasAncestryWithName`, `hasAttribute` and
  `hasAccess` are gone from the rule and feat prerequisite schemas. No record used them. Use
  `hasTrait`, `hasAttributeModifier` and the other kinds that remain.
- **Descriptor value types.** Six value types that no effect used are gone from the core descriptor:
  `skill-increase`, `character-feature`, `roll-modifier`, `roll-modifier-numeric`, `armor-kind` and
  `type-of-value`.
- **`listField`.** A field of every item of a list is not an input source. Read the list with
  `{choiceList: $.list}`, or one item's field with a field read. The projection `$.list[].field` stays
  in the `name` of a `hasChoice` condition.
- **Older spellings of a choice.** `freeText: <type>` (write `type:` on the choice and
  `freeText: true`), `records: {filter, type}` (write `type:` on the choice), and `optionsFrom` beside
  `records` (write `records: {filter, from}`).
- **`duplicateSelectionRules`.** A feat's `repeatPolicy` no longer has this key. It changed nothing:
  every copy of a repeatable record already leaves out the answers of the copies before it.

### Facts Blocks

A record can state facts about itself under `facts:`. A publication declares each fact once for a
collection, with its type, in `facts` of its `publication.yml`. A mechanics descriptor can declare facts
too (`facts`). The reference is [Facts](../reference/filters.md#facts-from-format-6).

What moved into facts:

- **Domains.** `domainSpell` and `advancedDomainSpell` are no longer plain fields of a domain. They are
  written under `facts:` as `@spell.…` references, in name order.
- **Bloodlines and mysteries.** Each bloodline states `advanced-bloodline-spell` and
  `greater-bloodline-spell`. Each mystery states `advanced-revelation-spell` and
  `greater-revelation-spell`. The feats that grant these spells hold one `grant-focus-spell` rule that
  reads the fact of the chosen record. They no longer hold one rule for each bloodline. A feat that
  asked for "a bloodline spell" now asks for the Bloodline Spells feature (for revelations,
  Revelation Spells).
- **Wizard schools.** Each school with an advanced school spell states it as `advanced-school-spell`. A
  description no longer repeats the school-spell block where the record's structure holds the spells.

A resource filter can test a fact with a `fact.<name>` leaf, and a `prerequisiteSkill` leaf tests the
skills a record's prerequisites ask for. The investigator's and swashbuckler's extra skill feats use
the second leaf to limit the skill feats on offer.

### Sorcerer Options

The Elemental and Draconic bloodlines no longer carry a gated rule for each answer. Each option has a
record of its own, in `draconic-exemplars/` or `elemental-influences/` under the sorcerer class. The
bloodline's question keeps its cases, so saved answers do not change, and each case adds the option's
record with an `add-feature` effect. What every option does the same is one rule in the bloodline.

### Rank Words

A rank is a word in a sheet expression: `untrained`, `trained`, `expert`, `master` or `legendary`.

- `(gte $.skills.diplomacy.rank 3)` is now `(gte $.skills.diplomacy.rank master)`.
- This holds for the reads `$.skills.<skill>.rank` and `$.spellcasting.proficiency`, in `gte`, `gt`,
  `lte`, `lt` and `eq`, with the read on either side.
- A comparison reads the words by position, so `master` is true for master and legendary.
- Comparing a rank read with a number is an error that names the word to use.
- Attribute reads and the level stay numbers.

The expression grammar gains a `word` token. See [Sheet Expressions](../reference/expressions.md).

### Own-Book Links

A link in a description to a record of the file's own publication is written without `?source=`:
`[Trip](omen://action/trip)`. A link to another publication keeps `?source=`. A link to a
collection stays unqualified. The decoded wire form still carries every link qualified, so a reader of
the JSONL or SQLite streams needs no change. A reader of authored YAML must read an unqualified record
path as the file's own publication.

Structured `omen://` values, review notes and `externalRecords` keep their `?source=`.

### Per-Item Rules

`forEach: <list>` on a rule runs the rule once for each item of a list. It was reserved and refused in
format 5.

- An input reads the item as `{item: true}`, or one field of an entry as `{item: true, field: name}`.
- A text input can hold `{item}`, `{item.field}` and `{$.path}`. The sequences `{{` and `}}` write
  braces.
- The output of each run depends on the rule and the item, so an item that leaves the list takes only
  its own output with it.

Two sheet functions read a list: `(count $.some.list)` and `(contains $.some.list item)`. See
[Character Lists](../reference/character-lists.md#rules-for-each-item).

### Engine Lists

Four effects now write lists that the engine reads. The descriptor declares them in `lists`:
`$.ancestry.feat-ancestries`, `$.class.key-attribute-options`, `$.skills.substitutions` and
`$.crafting.formulas`. A list in a descriptor can have `access: engine-write`, which means only the
engine writes it. An input in a descriptor can have `alsoAccepts`, a list of other value types it
takes (`add-feature` takes a heritage).

### New Fields and Constructs

- **`unsupportedCategory`.** A record with an `unsupportedReason` has an `unsupportedCategory`: one of
  `numbers`, `choice`, `benefit`, `text` and `scope`. The reason stays for the author, and the
  category is what tools count. A record with `mechanicsScope: builder` has neither. The field is on
  the ancestry, class, feat, feature, heritage, item and spell records, and on the shared
  mechanics-support block that actions and backgrounds use.
- **`vocabularies`.** A `publication.yml` can declare vocabularies, or add terms to a vocabulary a
  mechanics module declares (`extends: <module alias>/<vocabulary>`). A descriptor declares
  `vocabularies` and gives an input a `vocabulary`. A weapon group, damage type, terrain, crafting
  specialty or roll target is a term of a vocabulary. See
  [Archive Format and Repository Layout](../reference/format-and-layout.md#publication-manifests).
- **`requires`.** A `publication.yml` lists the publication ids it needs. A reference, prerequisite or
  grant that names a record of another publication with `?source=` fails when that publication is not
  listed. A record in `externalRecords` and a link in a description do not count.
- **Roll targets.** A roll target is a word, a list of words, or a `{description: […]}` of the targets
  the descriptor lists. An element outside them is an error that names the field and the accepted
  ones.
- **Prerequisite with an expression.** A feat's prerequisite can be `{when: (…), text: …}`: a
  condition over builder state, with the text the player reads.
- **`add-modifier@2`.** `amount` is a number or an expression, such as
  `(add 1 (gte $.skills.crafting.rank master))`.
- **Level 0 features.** A class feature that is reference text only (Warden Spells, Patron Theme and
  Witch Lessons) is at level 0. The feature schema allows level 0.
- **Optional `skillFeat`.** A background with no skill feat to name leaves out `skillFeat`. A blank
  one is refused.
- **Custom groups.** The format manifest declares `draconic-exemplars` and `elemental-influences` for
  the sorcerer, and `masterful-hunter` for the ranger.

### The Closed-Object and Limits Rules

- **Closed objects.** A key the schema does not list is an error in every object. A reader of an older
  version refuses a key it does not know, so a new field raises the version.
- **Ranges.** A count, a page number and a hit-point value have the range its schema gives. A name, a
  description, a trait and a reference are not empty.
- **YAML.** An authored file is UTF-8 and read with the YAML 1.2 core schema. Quote any scalar that
  would read as a boolean, a date, or a number other than decimal.
- **Limits.** One authored file is at most 1,048,576 bytes and 100,000 nodes, and uses no YAML anchors
  or aliases. A reader refuses a file over a limit, and names the file and the limit.

## Records That Moved

Three Ranger records of Player Core move from `class/ranger/features/` to
`class/ranger/masterful-hunter/`. They keep their names, and the same publication holds them.

| Format 5 path | Format 6 path |
|---|---|
| `class/ranger/features/masterful-hunter-flurry` | `class/ranger/masterful-hunter/masterful-hunter-flurry` |
| `class/ranger/features/masterful-hunter-outwit` | `class/ranger/masterful-hunter/masterful-hunter-outwit` |
| `class/ranger/features/masterful-hunter-precision` | `class/ranger/masterful-hunter/masterful-hunter-precision` |

The OmenPath of each record changes with its path:
`omen://class/ranger/features/masterful-hunter-flurry?source=paizo-pathfinder-player-core` becomes
`omen://class/ranger/masterful-hunter/masterful-hunter-flurry?source=paizo-pathfinder-player-core`. A
store that keys records by OmenPath sees three records removed and three added.

The reason is the rules of the game. A class grants every record in its `features` folder at that
record's level, so every Ranger held all three upgrades at 17th level. Now the `masterful-hunter`
feature holds one `add-feature` rule for each hunter's edge, and it applies only when
`$.ranger.hunters-edge` is that edge. The class does not grant the new folder.

## Format 5 Schemas

The schemas of format 5 stay in `docs/migrations/format-5-schemas/` for one release window. A reader
that cannot move yet can validate an archive of format 5 against them. They are not kept after the
window.

## Counts and the map

The first migration pass ran 27 steps across 1,428 files. Its own-book link step compacted 2,217 links across 1,183 files. Subsequent reviewed refreshes and normalization also changed files.

A comparison of record paths before and after the run finds 3,889 and 3,921 records respectively: 35 paths added and three removed, after Unicode NFC normalization. The three removals are the Ranger moves above. Déjà Vu's filename changed Unicode encoding without changing its identity. The current archive has 640 records with an `unsupportedReason`; all have a category: 249 numbers, 231 text, 115 benefit, 40 choice and five scope. Among 60 records whose scope was adjusted during the run, the final comparison shows 53 moving from encounter to mixed, three from unspecified to encounter, three from mixed to encounter, and one from encounter to builder. The three level-zero class features are the ones listed above.

The [machine-readable migration map](format-6-map.json) identifies the three moves and lists the files and change counts for each migration step. The step counts describe the first pass, rather than the complete before-and-after record comparison.
