# Turkish translation brief (tr)

This brief is for translation agents working on `OmenArchive/l10n/tr/`. Read it before every
batch. The archive's English records remain the single source of truth for mechanics; translation
is a text overlay.

## First pass: nomenclature only

The owner's priority is **names and terminology**, not descriptive prose. In `names` mode, translate
the `name` field only. Leave every description, trigger, requirement and outcome in English; the app
falls back per field. Do not fill prose fields in this pass.

The terminology and style reference is [`GLOSSARY.md`](GLOSSARY.md). Use its owner-approved
terms. A term marked complementary fills a gap; it does not replace an older owner-approved term
or a verified project decision. When those sources conflict, [`DECISIONS.md`](DECISIONS.md) and
the approved taxonomy entries preserve the earlier decision. Record new unresolved choices in
your batch decision file rather than silently changing an approved term.

## Non-negotiables

- Translate **text values only**. Never change a record key, never add a field, never move a file.
- Keep canonical `omen://...?source=...` keys exactly as they appear in the input JSON.
- Keep numbers, dice (`7d8`), distances, Bulk, action counts, `@` references, URLs and trait slugs
  unchanged.
- Do not translate proper nouns: deity names (Abadar, Iomedae), places (Absalom, Golarion),
  organizations, and the product names Pathfinder / Paizo.
- Every non-empty field in the input must be present and translated in the output. `name` is
  mandatory.
- Do not add commentary inside values. If a term is unresolved, put `# QUERY: ...` at the top of
  the output file and keep going.

## Voice and style

- Modern spoken tabletop Turkish, second person plural (`siz`: "atarsınız", "seçebilirsiniz").
  Never use `sen`/`senin`.
- Present tense, active voice, short sentences. Prefer established TTRPG phrasing over literal
  calques.
- Names use title case, one capital per word: `Reaktif Vuruş`, `Sıfır Mesafe Duruşu`.
- Keep the source's paragraph breaks. Do not merge separate rules paragraphs.
- Use Turkish punctuation and diacritics (`Zekâ`, `İrade`, `Açık RYO`). Apostrophe for suffixes on
  proper nouns: `Abadar'ın`.
- Avoid English word order. Read the sentence, then say it the way a Turkish game master would.

## Core glossary

| English | Turkish |
|---|---|
| ancestry / heritage | ecdad / miras |
| background | geçmiş |
| class | sınıf |
| class names | Magus, Psychic, Sorcerer, Summoner, Wizard, Thaumaturge, Witch |
| feat | hüner |
| spell / cantrip / focus spell | büyü / Kantrip / Odak Büyüsü |
| item / equipment | eşya / teçhizat |
| archetype / domain | arketip / alan |
| tradition (arcane, divine, occult, primal) | gelenek (mistik, ilahi, okült, doğa) |
| attribute / modifier | nitelik / Nitelik Değiştiricisi |
| Armor Class / Hit Points | Savunma Değeri (SD) / Can Puanı (CP) |
| Fortitude / Reflex / Will save | Dayanıklılık / Refleks / İrade Kurtarışı |
| Perception | Dikkat (DİK) |
| proficiency (untrained…legendary) | yetkinlik (eğitimsiz…efsanevi) |
| action / reaction / free action | eylem / reaksiyon / serbest eylem |
| Stride / Step / Strike | Depar / Adım / Vuruş Yap |
| multiple attack penalty | Çoklu Saldırı Cezası (ÇSC) |
| spell rank / spell slot | büyü derecesi / büyü slotu |
| heightened / sustained / refocus | güçlendirilmiş / sürdürülen / Odak Yenile |
| check / DC / save | test / ZD (zorluk değeri) / kurtarış |
| creature / target / ally / enemy | yaratık / hedef / müttefik / düşman |
| turn / round / encounter | sıra / tur / çatışma |
| explore / downtime | keşif / boş zaman |
| trait / rarity | etiket / nadirlik |
| common / uncommon / rare / unique | yaygın / ender / nadir / eşsiz |
| condition | durum |
| game master (GM) | Oyun Yöneticisi; metinde GM |
| NPC | OYV (oyuncu olmayan karakter) |
| skill | beceri (bkz. `taxonomy/skills.yml`) |

Conditions, actions, defenses and proficiencies have entries in
`l10n/tr/taxonomy/*.yml`. Keep those entries aligned with the effective glossary terms above and
with any older owner-approved decision that the glossary marks as complementary. The generic term `focus` remains `Fokus` per D056; use the glossary's `Odak` forms for the specific Focus Spell, Focus Point and Refocus entries.

## Full-pass addendum (prose)

The input `name` is the settled Turkish name: copy it unchanged, even if you would phrase it
differently. Do not retranslate it. Prose must use the settled names from the overrides and the taxonomy. In a prose
pass write terminology notes to `l10n/.work/tr/decisions-prose/<taskId>.md`, never to
`l10n/.work/tr/decisions/`, so the name ledger stays clean.

## Field guidance

- `name`: the display name only. No level, rank, trait or parenthetical unless the English name
  has one. In `names` mode this is the only field you write.
- `context` in the input is an English hint, not text to translate. Open the source record under
  `src/<publication>/<family>/...` when a name is ambiguous.
- `description`: full rules prose. Translate everything, including outcome paragraphs that were
  folded into the description. If it starts with a bare label (`Effect `, `Trigger `, `Special `),
  keep the label and a colon: `Etki: ...`; never run the label into the sentence.
- Source prose can contain internal markers such as `fortitude|against:rogue` or
  `survival|against:survival|options:action:track`. Translate only the part before the first `|`
  and never copy a `|` marker into the output.
- Some records arrive with engine tokens replaced by opaque placeholders like `%%T1%%`, `%%T2%%`.
  These stand for damage types (`[persistent,fire]`), save markers, formulas and similar
  internals. Copy every placeholder through unchanged, in place, and never translate, expand,
  reorder, drop or duplicate one. Translate the words around it. A dropped placeholder makes the
  merge keep that field in English.
- `trigger`, `requirements`, `frequency`, `special`: translate fully; keep `Frequency` phrasing
  natural (`Günde bir kez`, `Turda bir kez`).
- `criticalSuccess`, `success`, `failure`, `criticalFailure`: translate the label content only
  (the merge writes the field name).
- `prerequisites`: one entry per source entry, same order. Translate the text; feat and feature
  names must match their own `name` translation elsewhere.

## Output contract

Write one YAML mapping per task. Keys are the exact input keys. Field order: `name`,
`description`, `trigger`, `requirements`, `frequency`, `special`, `prerequisites`,
`criticalSuccess`, `success`, `failure`, `criticalFailure`. In `names` mode every value is just
`name`.

```yaml
omen://feat/example?source=paizo-pathfinder-player-core:
  name: Örnek Hüner
  description: >
    Birinci paragraf.

    İkinci paragraf.
  prerequisites:
  - text: Eğitimli Atletizm
```

- Use `>` for multi-line prose and a plain or double-quoted string for one line.
- Prerequisites are always a list of `- text: "..."` entries.
- The file must parse as YAML and contain only keys present in the input.

## Workflow

1. Read this brief, then every file in `l10n/tr/taxonomy/`.
2. Read the input JSON for your task. It lists the canonical key and the English fields.
3. Read `l10n/tr/<publication>/overrides/<family>.yml` if it exists, for established wording.
4. Translate every record. Write only your assigned output path under `l10n/.work/tr/out/`.
5. Write proposed terminology decisions to `l10n/.work/tr/decisions/<taskId>.md`, one row per
   choice: `| term | proposal | alternatives | reason |`. Only recurring or contested choices;
   individual feat names do not need rows.
6. Self-check before finishing: same key set, no empty `name`, no untranslated sentence, taxonomy
   terms exact, valid YAML.
7. Never run `git`, never edit archive sources or another task's output. If a neighbouring task's
   terminology affects yours, message that agent (roster supplied in the task prompt) instead of
   editing their file.

## Review bar

A nomenclature batch is acceptable when every name reads like a term a Turkish game master would
use out loud, the same English term maps to the same Turkish term across families, and no name is
a literal calque or an untranslated English phrase.
