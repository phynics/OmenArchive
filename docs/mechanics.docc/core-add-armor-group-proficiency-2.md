# core/add-armor-group-proficiency@2

Grants proficiency in an armor category. When includeLowerArmors is true, all lighter armor categories are also granted. When selfScaling is true, granted proficiencies scale alongside unarmored defense.

Effect `add-armor-group-proficiency`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `armorGroup` | `armor-kind` | yes |
| `proficiencyRank` | `proficiency-rank` | yes |
| `includeLowerArmors` | `bool` | yes |
| `selfScaling` | `bool` | yes |

## Writes

- domain `armor-proficiency`, name `armor`

## Usage in the archive

Used by 0 rules.
