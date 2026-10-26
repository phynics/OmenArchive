# core/add-character-trait

Grants a general trait to the character (e.g. undead, construct, amphibious).

Effect `add-character-trait`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `trait` | `string` | yes |

## Writes

- domain `trait`, name input `trait`

## Usage in the archive

Used by 6 rules.

Example, from `paizo-pathfinder-player-core/ancestry/gnome/heritages/fey-touched-gnome.yml`:

```yaml
- key: add-character-trait-1
  effect: core/add-character-trait
  inputs:
    trait: fey
```
