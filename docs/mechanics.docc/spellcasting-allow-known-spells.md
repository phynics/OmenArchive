# spellcasting/allow-known-spells

Lets the player pick a number of spells for a spellcasting source's repertoire or spellbook in its collection editor; grants none itself.

Effect `allow-known-spells`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `source` | `source-key` | yes |
| `count` | `int` | yes |
| `pick` | `spell-pick` | yes |
| `filter` | `resource-filter` | yes |

`source` is the key of a spellcasting source the publication declares in `spellcastingSources`, such as `ranger-focus-spells`. The wire form calls the input `sourceId` and holds the source's ID.

## Usage in the archive

Used by 0 rules.
