# Sheet Expressions

A sheet expression computes a whole number from the character: how many uses a pool has, how much a
modifier adds, or whether a rule applies. This page describes the expression language of the current
format.

## Where expressions appear

An input that takes a sheet value takes either a whole number or an expression. In this archive they
appear in:

| Field | What the number means | Example |
|---|---|---|
| `value`, `amount` | A number added or set | `value: (max 1 (divide $.level 2))` |
| `maximum` | A pool's size | `maximum: (add 2 $.attributes.int)` |
| `requires` | A condition: the rule applies when it is 1 | `requires: (gte $.skills.diplomacy.rank master)` |

In an authored file an expression is bare, as above. The decoded wire form wraps it as
`[[ (max 1 (divide $.level 2)) ]]`; both forms mean the same thing.

## Grammar

```text
expression := number | read | word | '(' name expression* ')'
number     := an integer or decimal literal, such as 2 or 0.5
read       := a $ path, such as $.level or $.skills.diplomacy.rank
word       := lowercase letters, digits and hyphens, such as master or athletics
name       := one of the operator names in the table below
```

Tokens are separated by spaces and parentheses. An expression is written in prefix form: the
operator comes first, then its arguments. A word is a rank (see [Ranks](#ranks)) or the item
argument of `contains`; it has no other use.

## Operators

| Operator | Arguments | Result |
|---|---|---|
| `add` | 1 or more | The sum |
| `subtract` | 2 | The first minus the second |
| `multiply` | 1 or more | The product |
| `divide` | 2 | The first divided by the second |
| `floor` | 1 | Rounded down |
| `ceil` | 1 | Rounded up |
| `min` | 1 or more | The smallest |
| `max` | 1 or more | The largest |
| `gte` | 2 | 1 if the first is greater than or equal to the second, else 0 |
| `gt` | 2 | 1 if the first is greater than the second, else 0 |
| `lte` | 2 | 1 if the first is less than or equal to the second, else 0 |
| `lt` | 2 | 1 if the first is less than the second, else 0 |
| `eq` | 2 | 1 if the two are equal, else 0 |
| `and` | 1 or more | 1 if every argument is 1 or more, else 0 |
| `or` | 1 or more | 1 if any argument is 1 or more, else 0 |
| `not` | 1 | 1 if the argument is less than 1, else 0 |
| `count` | 1 | The number of items of a list. The argument is the `$` path of a declared list |
| `contains` | 2 | 1 if a list has an item, else 0. The first argument is the `$` path of a declared list |

## Numbers and conditions

- **A condition is a number.** The comparison operators and `and`, `or` and `not` give 1 when they
  hold and 0 when they don't. A condition can be used in arithmetic: `(add 1 (gte
  $.spellcasting.proficiency master))` is 2 for a master and 1 below.
- **A condition holds when its value is 1 or more.** `requires` applies its rule only then.
- **Rounding happens once, at the end.** Intermediate values keep their fractions, and the final
  value is rounded down to a whole number. `(divide $.level 2)` at 5th level is 2.5 while it is
  computed, and 2 as the result. `floor` and `ceil` round where they are written.

## Reads

A read is a `$` path that gives a whole number. The engine provides these:

| Read | Value |
|---|---|
| `$.level` | The character's level, 1 to 20 |
| `$.attributes.<str, dex, con, int, wis or cha>` | The attribute modifier |
| `$.skills.<skill>.rank` | The skill's proficiency rank, compared with a rank word |
| `$.armor.<unarmored, light, medium or heavy>.rank` | The proficiency rank in that kind of armor, compared the same way |
| `$.spellcasting.proficiency` | The character's spell attack and spell DC rank, compared the same way |
| `$.class.dc` | The class DC of the character's class |
| `$.class.<class>.dc` | The class DC of a class the character has |
| `$.feats.<feat>.class-dc` | The class DC a feat uses |
| `$.archetype.<archetype>.feat-count` | How many feats the character has from that archetype, dedication included |

A read can also name a question the record's rules declare, when its answer is a whole number. Reads
that give text or lists, such as `$.ancestry.name`, can't be used as a value in an expression. A list
can be the first argument of `count` and `contains`.

## Ranks

A rank is a word in an expression: untrained, trained, expert, master or legendary. A comparison reads
the words by position, so `(gte $.skills.diplomacy.rank master)` holds for master and legendary.
Comparing a rank read with a number is an error that names the word to use. Attribute reads and the
level stay number.

**When a rank is read.** A skill or armor rank that a rule's condition reads is the rank the character
holds as the level begins, plus the skill increases the player chose for that level. A rank another rule
grants at the same level doesn't count until the next level, so a rule that offers an option by rank
offers the same options whatever order the level's other rules apply in. A `hasChoice` on one of these
reads and an expression that reads one are read alike.

## Counting a list

`(count $.some.list)` is the number of items of a list a rule declares (0 when the character has
none). `(contains $.some.list item)` is a condition: it holds when the list has the item. The first
argument is the `$` path of a declared list. The item is a bare word such as `athletics`, a number, or
the `$` path of a question's answer. Both take part in arithmetic and comparisons like any other value,
so `(multiply 2 (count $.feats.my-feat.skills))` gives two hit points per item. The operator table
lists `count` (one argument) and `contains` (two). See [Character lists](character-lists.md).

## When an expression can't be evaluated

An expression has no value when it is malformed (an unmatched parenthesis, an unknown operator or a
wrong number of arguments), when it divides by zero, or when a read names nothing the character has.
Such an expression has no value. It is never read as 0 or as a condition that doesn't hold: a reader
shows it as not checked, and leaves the decision to the player. `omen-archive validate` reports each of
these mistakes with the record and the line, so check an archive before publishing it.

## Examples from the archive

| Expression | At | Value |
|---|---|---|
| `(max 1 (divide $.level 2))` | 1st level; 7th level | 1; 3 |
| `(floor (divide $.level 2))` | 7th level | 3 |
| `(add 2 $.attributes.int)` | Intelligence +3 | 5 |
| `(multiply 3 $.archetype.fighter.feat-count)` | two fighter archetype feats | 6 |
| `(gte $.skills.diplomacy.rank master)` | master in Diplomacy; expert | 1; 0 |
| `(and (gte $.attributes.str 5) (gte $.skills.intimidation.rank master))` | Strength +5, master in Intimidation | 1 |
| `(multiply 2 (count $.feats.my-feat.skills))` | three skills on the list | 6 |
