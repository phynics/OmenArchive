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
- `$.list[].field` reads one field of every item, in list order, with duplicates kept, in a condition (the `name` of a `hasChoice`). A rule input may not read it: use `{choiceList: $.list}`. The field must be one the list's items have: an entry's declared field, or a field of a record. A record field may follow an entry field (`$.deity.spells[].spell.traits`). There is no `[n]`: a position is unstable, so a rule that needs one item filters on a field.

A declaration, an `add-to-list` target and a saved answer's address take the plain path; `[]` is refused there.

## Rules for each item

`forEach: <list>` on a rule runs the rule once for each item of a list, after the character's other rules. The list is a plain `$` path of a declared list, and a rule that writes it is refused. An input reads the item as `{item: true}`, or one field of an entry as `{item: true, field: name}`. A text input may hold `{item}` or `{item.field}` for the item and `{$.path}` for the answer to a question; the whole text is the string a translation replaces, `{{` and `}}` write braces. The output of each run depends on the rule and the item, so an item that leaves the list takes only its own output with it.

## Lists the engine declares

| List | Holds | Module |
|---|---|---|
| `$.ancestry.feat-ancestries` | `string` | `core` |
| `$.class.key-attribute-options` | `attribute` | `core` |
| `$.skills.substitutions` | entries of `skill` (`skill`), `substitute` (`skill`) | `core` |
| `$.crafting.formulas` | any record under `omen://item` | `core` |
