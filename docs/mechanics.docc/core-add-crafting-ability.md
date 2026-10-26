# core/add-crafting-ability

Configures a special crafting ability with daily preparation slots and craftable item filters (e.g. infused reagents, snares).

Effect `add-crafting-ability`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `slug` | `string` | yes |
| `label` | `string` | yes |
| `maxSlotsExpression` | `string` | yes |
| `isDailyPreparation` | `bool` | yes |
| `craftableItems` | `string` | yes |

## Usage in the archive

Used by 2 rules.

Example, from `paizo-pathfinder-player-core/feat/cauldron.yml`:

```yaml
- key: add-crafting-ability-1
  effect: core/add-crafting-ability
  inputs:
    slug: cauldron
    label: PF2E.SpecificRule.Witch.Cauldron.CraftingEntry
    maxSlotsExpression: ternary(eq(@actor.system.proficiencies.spellcasting.rank,4),3,ternary(eq(@actor.system.proficiencies.spellcasting.rank,3),2,1))
    isDailyPreparation: true
    craftableItems: or(item:trait:oil,item:trait:potion)
```
