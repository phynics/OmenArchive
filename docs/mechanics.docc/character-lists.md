# Character lists

A list is a declared, typed, derived set of items on a character: the skills it has Assurance in, the orders it counts as a member of. Rules add items to it and read it. It is rebuilt at every level from the rules, so a list holds nothing only the player can change, and it is never saved.

## Declaring

A record declares a list with `declare-list`, naming it by its plain `$` path (no `\$` escape, no `[]`) and what it holds:

```yaml
- key: assurance-list
  effect: core/declare-list
  inputs:
    list: $.feats.assurance.skills
    valueType: core/skill
    label: Assurance
```

`valueType` is one of:

- a value type, `core/skill`;
- `{records: '@class.druid.orders'}`: any record under that collection, from any publication, so a new book's records need no edit to the list;
- `{entry: {rank: core/int, spell: {records: '@spell'}}}`: an entry of named fields. An entry's identity is all its fields together.

Declaring the same list again with the same type changes nothing; a different type is an archive error. Only the feat `<feat>` declares names under `$.feats.<feat>`; any record may add to a list there or read it. A list the archive declares that a character doesn't have reads as empty. A name no record declares is an archive error.

## Adding

`add-to-list` adds one item: a question's answer, or a value written with its type.

```yaml
- key: add-athletics
  effect: core/add-to-list
  inputs:
    list: $.feats.assurance.skills
    value: {type: core/skill, literal: athletics}
```

A list is a set. The same value from two sources is one item with two origins (the rule, and the record and copy that holds it), and removing one source keeps the item.

A question can name the list its answer goes to:

```yaml
- key: choice-assurance-skill
  choice:
    name: $.feats.assurance.skill
    label: Skill
    type: core/skill
    addTo: $.feats.assurance.skills
    cases:
      - {key: acrobatics, value: acrobatics}
      - {key: athletics, value: athletics}
```

The reader expands `addTo` into an `add-to-list` rule keyed `<question key>-add`, and into a `distinct` over the same list, so the question leaves out the items already on it. `distinct: false` lets the answer repeat an item. The wire form carries only the expanded rules.

## Leaving items out

`distinct: {list: $.feats.assurance.skills}` leaves out the items already on a list. It is one-way: a question leaves out only items that rules authored before it added, so retraining an earlier copy never invalidates a later one.

## Reading

- `hasChoice: {name: $.druid.orders, contains: …}` tests a list for a value.
- `{choiceList: $.list}` reads a list that a rule or a question has declared or added to.
- `$.list[].field` reads one field of every item, in list order, with duplicates kept. It is short for `{list: $.list, field: field}`. The field must be one the list's items have: an entry's declared field, or a field of a record. A record field may follow an entry field (`$.deity.spells[].spell.traits`). There is no `[n]`: a position is unstable, so a rule that needs one item filters on a field.

A declaration, an `add-to-list` target and a saved answer's address take the plain path; `[]` is refused there.

## Reserved

`forEach: <list>` on a rule is reserved for rules that run once for each item. It is not supported yet, and a rule that uses it is refused.

## Lists the engine declares

| List | Holds | Module |
|---|---|---|
| `$.ancestry.feat-ancestries` | `string` | `core` |
| `$.class.key-attribute-options` | `attribute` | `core` |
| `$.skills.substitutions` | entries of `skill` (`skill`), `substitute` (`skill`) | `core` |
| `$.crafting.formulas` | any record under `omen://item` | `core` |
