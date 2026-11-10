# core/add-weapon-critical-specialization

Unlocks the critical specialization effect for all weapons within a weapon group.

> **Removed in format 6.** A format 6 reader refuses this effect. Write an `add-note` rule on attack rolls instead, with the condition the record states.

Effect `add-weapon-critical-specialization`, revision 1, from module `me.atkn.omen.pf2e.playercore`.

## Inputs

| Input | Type | Required |
|---|---|---|
| `uuid` | `uuid` | yes |
| `weaponGroup` | `weapon-group` | yes |

Derived from the rule key, never written: `uuid`.

## Writes

- domain `roll-modifier`, name `roll-modifier`

## Usage in the archive

Used by 5 rules.

Format 6 replacement, from `paizo-pathfinder-player-core/class/bard/features/bard-weapon-expertise.yml`:

```yaml
- key: weapon-critical-specialization-note
  effect: core/add-note
  inputs:
    target: attack-rolls
    text: When you critically succeed at an attack roll using a martial weapon, a
      simple weapon or an unarmed attack while one of your compositions is active,
      you apply the critical specialization effect for that weapon or unarmed attack.
    when: One of your compositions is active
```
