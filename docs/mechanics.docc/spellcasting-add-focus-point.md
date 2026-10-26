# spellcasting/add-focus-point

Increases the character's focus pool capacity by 1 point, up to the maximum pool size of 3.

Effect `add-focus-point`, revision 1, from module `me.atkn.omen.pf2e.playercore-spellcasting`.

## Inputs

This effect takes no inputs.

## Usage in the archive

Used by 117 rules.

Example, from `paizo-pathfinder-player-core/feat/masterful-warden.yml`:

```yaml
- key: warden-focus-point
  effect: spellcasting/add-focus-point
  prerequisites:
  - hasChoice:
      name: $.feat.masterful-warden.spell
      isSet: true
```
