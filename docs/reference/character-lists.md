# Character Lists

A **list** is a declared, typed, derived set of items on a character: the skills it has Assurance in, the orders it counts as a member of, the ancestries whose feats it can take. Rules add items to a list and read it. A list is rebuilt at every level from the rules, so it holds nothing only the player can change, and it is never saved with the character.

A list is named by a plain `$` path (`$.feats.assurance.skills`). A **question** is a different thing: one decision of one copy of a record (`$.feats.assurance.skill`). A name is a question or a list, never both; the archive check rejects a name used both ways.

## Declaring a list

`core/declare-list` declares a list: its name, what it holds and, optionally, a label for display and localization.

```yaml
- key: assurance-list
  effect: core/declare-list
  inputs:
    list: $.feats.assurance.skills     # a list path: no \$ escape
    valueType: core/skill
    label: Assurance
```

`valueType` is one of:

| Spelling | An item is |
|---|---|
| `core/skill` | one registered value of that type |
| `{records: '@class.druid.orders'}` | any record under that collection, from any publication. A new book's records need no edit to the list, the records that add to it or the prerequisites that read it |
| `{entry: {rank: core/int, spell: {records: '@spell'}}}` | an entry of named fields (each a value type or `{records: …}`). An entry's identity is all its fields together |

Declaring the same list again with the same type changes nothing, so each copy of a repeatable record can declare it. A different type for the same name is an archive error. The archive check knows every declaration, so it types writers and readers statically.

**Namespaces.** Only the feat `<feat>` declares names under `$.feats.<feat>`; any record may add to a list there or read it. The engine's built-in values under `$.feats.<feat>` (`class-dc`) stay reserved. Class and shared roots (`$.druid.*`, `$.deity.*`) are declared by the records that own them.

**Reading a list nobody has contributed to.** A list the archive declares but a character doesn't have reads as empty, so "has Assurance in Athletics" is false without Assurance. A name no record declares is an archive error.

**Engine lists.** A mechanics module declares lists for the engine in its descriptor (`lists`), such as `$.ancestry.feat-ancestries`. Rules add to and read them like any other; no record declares them.

## Adding to a list

`core/add-to-list` adds one item. `list` is a list path and `value` is one item: a question's answer, or a value written with its type.

```yaml
- key: add-assurance-skill
  effect: core/add-to-list
  inputs:
    list: $.feats.assurance.skills
    value: {choice: $.feats.assurance.skill}

- key: add-athletics
  effect: core/add-to-list
  inputs:
    list: $.feats.assurance.skills
    value: {type: core/skill, literal: athletics}

- key: add-spell
  effect: core/add-to-list
  inputs:
    list: $.feats.fixture.spells
    value:
      entry:
        rank: {type: core/int, value: 1}
        spell: {type: spellcasting/spell-id, value: '@spell.heal'}
```

A list is a **set**: the same value from two sources is one item with two origins. Each origin is the rule that added it and the record and copy that holds the rule, so a builder can show why an item is on a list. Removing one source keeps the item. Rules cannot read origins.

The archive check types the value against the list's declaration: a value type must match, an entry needs exactly the declared fields, and a record must be under the declared collection.

### `addTo` on a question

A question can name the list its answer goes to:

```yaml
- key: choice-assurance-skill
  choice:
    name: $.feats.assurance.skill
    label: Skill
    type: core/skill
    addTo: $.feats.assurance.skills     # adds the answer; leaves out skills already on the list
    cases:
      - {key: acrobatics, value: acrobatics}
      - {key: athletics, value: athletics}
```

The reader expands `addTo` into the `add-to-list` rule above, keyed `<question key>-add`, and into a `distinct` over the same list. The wire form (`omen-archive wire`) carries only the expanded rules, so tools and presenters treat both spellings alike. Writing `add-to-list` by hand stays valid for rules that add something other than a question's answer. A question with `multiple:` can't use `addTo`.

## Leaving items out

`distinct` is the one "different from" field of a question. Beside a `$` path (another question or a built-in), it takes the items of a list:

<!-- docs-check: not a whole example — two spellings shown on their own -->
```yaml
distinct: {list: $.feats.assurance.skills}
distinct: [$.ancestry.name, {list: $.feats.assurance.skills}]
```

It is **one-way**: a question leaves out only items that rules authored before it added (earlier copies, earlier levels), so retraining an earlier copy never invalidates a later one. `addTo` implies it for its own list; `distinct: false` lets a question's answer repeat an item already on the list.

## Reading a list

- `hasChoice: {name: $.druid.orders, contains: '@class.druid.orders.leaf'}` tests a list for a value. The value is bare because the list's declaration gives its type; a test of anything else (a repeatable choice, a list nobody declares) spells the type: `contains: {type: core/int, value: 1}`.
- `(count $.list)` and `(contains $.list item)` read a list in a [sheet expression](expressions.md#counting-a-list): the number of items, and whether the list has one.
- `{choiceList: $.list}` reads a list as an input once a rule has declared it or added to it.
- `$.list[].field` reads **one field of every item**, in list order, duplicates kept: `$.deity.spells[].rank` is the list of the `rank` fields of the entries of `$.deity.spells`. A condition (the `name` of a `hasChoice`) may project. A rule input may not: from format 6 a field of every item is not an input source, so read the list with `{choiceList: $.list}` or one item's field with a field read.
  - The field is typed against the declaration. For an entry list it is one of the entry's declared fields; for a record list, a field of the record. A field of a record may follow an entry field: `$.deity.spells[].spell.traits`.
  - There is no `[n]`: a position is unstable, so a rule that needs one item filters on a field.
  - `[]` makes the path a query. A declaration, an `add-to-list` target and a saved answer's address take the plain path, and refuse `[]`.

## Rules for each item

`forEach: <list>` on a rule runs the rule once for each item of a list, after the character's other rules. The list is a plain `$` path of a declared list, and a rule that writes it is refused. An input reads the item as `{item: true}`, or one field of an entry as `{item: true, field: name}`. A text input may hold `{item}` or `{item.field}` for the item and `{$.path}` for the answer to a question; the whole text is the string a translation replaces, `{{` and `}}` write braces. The output of each run depends on the rule and the item, so an item that leaves the list takes only its own output with it.
