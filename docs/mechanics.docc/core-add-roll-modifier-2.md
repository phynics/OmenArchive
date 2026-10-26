# core/add-roll-modifier@2

Adds an active modifier or informative rule note to checks matching the target roll description.

Effect `add-roll-modifier`, revision 2, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `uuid` | `uuid` | yes |
| `target` | `roll-description` | yes |
| `description` | `string` | yes |
| `numeric` | `roll-modifier-numeric` | no |

Derived from the rule key, never written: `uuid`.

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 69 rules.

Example, from `paizo-pathfinder-player-core/ancestry/goblin/heritages/irongut-goblin.yml`:

```yaml
- key: add-roll-modifier-1
  effect: core/add-roll-modifier@2
  inputs:
    target:
      description:
      - anyNonPerceptionSavingThrow: {}
    description: 'Irongut Goblin: +2 circumstance bonus to saving throws (in some
      situations).'
    numeric: {literal: {amount: 2, applicability: {description: in some situations,
          kind: situational}, type: circumstance}}
```
