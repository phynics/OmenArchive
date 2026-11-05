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
| `requires` | A condition: the rule applies when it is 1 | `requires: (gte $.skills.diplomacy.rank 3)` |

In an authored file an expression is bare, as above. The decoded wire form wraps it as
`[[ (max 1 (divide $.level 2)) ]]`; both forms mean the same thing.

## Grammar

```text
expression := number | read | '(' operator expression* ')'
number     := an integer or decimal literal, such as 2 or 0.5
read       := a $ path, such as $.level or $.skills.diplomacy.rank
operator   := one of the names in the table below
```

Tokens are separated by spaces and parentheses. An expression is written in prefix form: the
operator comes first, then its arguments.

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

## Numbers and conditions

- **A condition is a number.** The comparison operators and `and`, `or` and `not` give 1 when they
  hold and 0 when they don't. A condition can be used in arithmetic: `(add 1 (gte
  $.spellcasting.proficiency 3))` is 2 for a master and 1 below.
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
| `$.skills.<skill>.rank` | The skill's proficiency rank: 0 untrained, 1 trained, 2 expert, 3 master, 4 legendary |
| `$.spellcasting.proficiency` | The character's spell attack and spell DC rank, on the same 0 to 4 scale |
| `$.class.dc` | The class DC of the character's class |
| `$.class.<class>.dc` | The class DC of a class the character has |
| `$.feats.<feat>.class-dc` | The class DC a feat uses |
| `$.archetype.<archetype>.feat-count` | How many feats the character has from that archetype, dedication included |

A read can also name a question the record's rules declare, when its answer is a whole number. Reads
that give text or lists, such as `$.ancestry.name`, can't be used in an expression.

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
| `(gte $.skills.diplomacy.rank 3)` | master in Diplomacy; expert | 1; 0 |
| `(and (gte $.attributes.str 5) (gte $.skills.intimidation.rank 3))` | Strength +5, master in Intimidation | 1 |
