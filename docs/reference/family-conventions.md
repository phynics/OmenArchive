---

## 8. Heritages and Versatile Heritages

- **Ancestry Heritage**: `src/{pub}/ancestry/{ancestry}/heritages/{slug}.yml`
- **Versatile Heritage**: `src/{pub}/versatile-heritage/{slug}.yml`
- **Schema**: `schemas/character-heritage.schema.json`

```yaml
name: seer elf
ancestry: elf
rarity: common
description: |
  You possess an instinctive grasp of magical energies...
```

For versatile heritages, set `ancestry: versatile` and use inline rules to grant ancestry traits (`add-character-ancestry-trait`) and senses.

---
