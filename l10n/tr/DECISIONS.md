# Turkish nomenclature decision ledger

Status values: `open` (needs the owner), `approved` (owner cleared), `rejected` (use the
alternative). Agents translate with the **proposal** while a row is `open`, so the first pass is
internally consistent; clearing a row later changes the term in one place and the affected
overrides are regenerated.

Add proposals from a translation batch under `l10n/.work/tr/decisions/<taskId>.md`; the next pass
folds them into this table. Do not edit an `approved` row without the owner.

## Glossary alignment notes

The glossary includes complementary entries that differ from earlier approved decisions. These
are documentation conflicts. Keep the approved ledger terms until the glossary is reconciled:

| Glossary entry | Approved ledger term | Decision |
|---|---|---|
| Ancestry: Soy | Ecdad | D001 |
| Reaction: Tepki | Reaksiyon | D006 |
| Stride: İlerle | Depar | D003 |
| Step: Adım At | Adım | D004 |
| Perception: Algı | Dikkat | D009 |
| Armor Class: Zırh Sınıfı | Savunma Değeri | D007 |

The translation brief and taxonomy follow the approved terms. Reconcile these glossary entries in
`GLOSSARY.md` in a separate glossary change; do not reinterpret the older approvals here.

## Core vocabulary

| ID | Scope | Proposal | Alternatives | Why it matters | Status |
|---|---|---|---|---|---|
| D001 | ancestry | Ecdad | Soy, Irk | Appears in every ancestry and heritage record; `Irk` has real-world baggage | approved |
| D002 | feat | Hüner | Yetenek, Kabiliyet | Thousands of records; must read naturally in prerequisites | approved |
| D003 | Stride | Depar | Atılma, Koşma | Core action, used in dozens of feat texts | approved |
| D004 | Step | Adım | — | Pairs with Depar | approved |
| D005 | action (unit) | Eylem | Aksiyon | Action economy is everywhere | approved |
| D006 | reaction | Reaksiyon | Tepki | `Tepki` reads as a response, not the rules unit | approved |
| D007 | Armor Class | Savunma Değeri (SD) | Zırh Sınıfı (ZS) | Already used by the seed | approved |
| D008 | saves | Saving Throw: Kurtarış; Fortitude / Reflex / Will: Dayanıklılık / Refleks / İrade Kurtarışı | Beden / Refleks / İrade Kurtarması | Owner-approved terminology update; keeps Constitution (`Bünye`) distinct from Fortitude (`Dayanıklılık`) | approved |
| D009 | Perception | Dikkat (DİK) | Algı | `Dikkat` also names the exploration activity | approved |
| D010 | background | Geçmiş | Köken | `Köken` collides with ancestry/heritage | approved |
| D011 | heritage | Miras | Kalıtım, Soy | Pairs with Ecdad | approved |
| D012 | spell rank / slot | Büyü Derecesi / Büyü Slotu | Büyü Kademesi / Büyü Seviyesi | Owner-approved update to rank; keeps rank distinct from character level | approved |
| D013 | traditions | Mistik / İlahi / Okült / Doğa | Arkana / Kutsal / Gizli / İlkel | Seed choice; `Doğa` also means nature generally | approved |
| D014 | check / DC | test / ZD (zorluk değeri) | kontrol / SD | `SD` already means Armor Class | approved |
| D015 | action names | Depar, Adım, Vuruş Yap, Reaksiyon, Serbest Eylem | Saldırı | Owner-approved update to Strike; other action names retain prior decisions | approved |
| D016 | proficiency ranks | Eğitimsiz, Eğitimli, Uzman, Usta, Efsanevi | — | Seed terms | approved |
| D017 | rarity | yaygın, ender, nadir, eşsiz | — | Gemini recommends this one-word progression; owner requested single-word labels | approved |
| D018 | register | second person plural (`siz`) | `sen` | Consistency across all prose | approved |
| D019 | name case | Title Case (`Reaktif Vuruş`) | sentence case | Existing overrides | approved |

## Classes

Owner decision: retain the class names Magus, Psychic, Sorcerer, Summoner, Wizard, Thaumaturge,
and Witch in English. Keep the generic term Spellcaster translated as Büyücü; it is distinct
from the Sorcerer and Wizard classes.

| ID | Scope | Proposal | Alternatives | Why it matters | Status |
|---|---|---|---|---|---|
| D020 | alchemist | Simyacı | Alkemi | Class name, appears in features and feats | approved |
| D021 | barbarian | Barbar | Vahşi | — | approved |
| D022 | bard | Ozan | Bard | `Ozan` is the established Turkish term | approved |
| D023 | champion | Şampiyon | — | — | approved |
| D024 | cleric | Rahip | Klerik | — | approved |
| D025 | druid | Druid | Doğacı | Keep the established loanword | approved |
| D026 | fighter | Savaşçı | Dövüşçü | — | approved |
| D027 | monk | Keşiş | Rahip (collides with cleric) | — | approved |
| D028 | ranger | Korucu | Ranger | — | approved |
| D029 | rogue | Düzenbaz | Hırsız | Owner prefers Düzenbaz | approved |
| D030 | sorcerer | Sorcerer | Seherbaz, Büyücü, Sihirbaz | Owner decision: retain the English class name as part of the mixed-origin caster-name set | approved |
| D031 | wizard | Wizard | Sihirbaz, Büyücü | Owner decision: retain the English class name as part of the mixed-origin caster-name set | approved |
| D032 | witch (class) | Witch | Cadı | Owner decision: retain the class name in English | approved |
| D033 | investigator | Müfettiş | Araştırmacı | — | approved |
| D034 | swashbuckler | Kılıçşör | Bıçkın, Cüretkâr | Gemini recommends pairing it with gunslinger Silahşör; owner still notes the sword-specific feel | open |
| D035 | oracle | Kâhin | Oracle | — | approved |
| D036 | magus | Magus | Savaşbüyücüsü | Owner decision: retain the established class name as part of the mixed-origin caster-name set | approved |
| D037 | summoner | Summoner | Çağırıcı | Owner decision: retain the English class name as part of the mixed-origin caster-name set | approved |
| D038 | thaumaturge | Thaumaturge | Tılsımcı, Taumaturg, Mucizecil | Owner decision: retain the English class name as part of the mixed-origin caster-name set | approved |
| D039 | psychic | Psychic | Medyum, Psişik | Owner decision: retain the English class name as part of the mixed-origin caster-name set | approved |
| D040 | inventor | Mucit | İcatçı | — | approved |
| D041 | gunslinger | Silahşör | Nişancı | `Nişancı` is broader | approved |

## Ancestries and heritages

| ID | Scope | Proposal | Alternatives | Why it matters | Status |
|---|---|---|---|---|---|
| D042 | dwarf | Cüce | — | Seed term | approved |
| D043 | elf | Elf | — | Seed term | approved |
| D044 | human | İnsan | — | Seed term | approved |
| D045 | goblin | Goblin | — | Seed term | approved |
| D046 | halfling | Buçukluk | Hobbit | Seed term; `Hobbit` is trademarked | approved |
| D047 | gnome | Gnom | Cüce (collides) | Seed term | approved |
| D048 | leshy | Leshy | Leşi | Setting/special ancestry name kept in English per GLOSSARY.md (never Leşi) | approved |
| D049 | orc | Ork | — | Seed term | approved |

## Naming conventions

| ID | Scope | Proposal | Alternatives | Why it matters | Status |
|---|---|---|---|---|---|
| D050 | class feature names | Translate (`Büyücülük`, `Silah Ustalığı`) | Keep English | Features appear beside feats in the builder | approved |
| D051 | feat names | Translate the whole name; keep proper nouns | Keep English | Nomenclature is the priority of this pass | approved |
| D052 | spell names | Translate the whole name; keep proper nouns | Keep English | Same | approved |
| D053 | item names | Translate (`Uzun Kılıç`, `Zincir Zırh`) | Keep English | Same | approved |
| D054 | proper nouns | Keep English spelling; Turkish suffix with apostrophe (`Abadar'ın`) | Transliterate | Deities, places, organizations | approved |
| D055 | stance | Duruş | Duruşma, Pozisyon | Recurring feat suffix | approved |
| D056 | focus | Fokus | Odak | Seed term | approved |
| D057 | familiar | Ruhdaş Hayvan | Ruhdaş | Owner decision: use an animal-forward term, standardized alongside Yoldaş Hayvan | approved |
| D058 | animal companion | Yoldaş Hayvan | Hayvan Yoldaşı | Owner decision: standardized alongside Ruhdaş Hayvan | approved |
| D059 | hero point | Kahraman Puanı | — | — | approved |
| D060 | exploration / downtime | Keşif / Boş Zaman | — | — | approved |
| D061 | anathema | Yasak | Lanet | `Lanet` already means a condition/curse | approved |
| D062 | doctrine | Öğreti | Doktrin | Cleric and oracle features | approved |
| D063 | muse | İlham Perisi | Muse | Bard subclass | approved |
| D064 | sneak attack | Sinsi Saldırı | Gizli Saldırı | Rogue core | approved |
| D065 | rage | Öfke | Hiddet | Barbarian core | approved |
| D066 | spellcasting | Büyücülük | Büyü Yapma, Büyü Savurma | Owner decision; use consistently for the Spellcasting feature and terminology | approved |
| D067 | trait names | English fallback until the taxonomy covers them | — | Not in the override schema yet | approved |
| D068 | versatile heritages | Keep invented names (Aiuvarin, Dromaar, Nephilim); translate common nouns (Changeling → Değişen) | Translate all / keep all | These read as species names, not descriptions | approved |
| D069 | background names | Translate the whole name (`Akademisyen`, `Suçlu`) | Keep English | Backgrounds are chosen by name in the builder | approved |

## Context-distinct names

A few English words name different rules objects and deliberately take different Turkish names.
Confirm these splits, or ask for one term where you prefer it.

| ID | Scope | Proposal | Alternatives | Why it matters | Status |
|---|---|---|---|---|---|
| D070 | fly | Uçma (action) / Uçuş (spell) | one term for both | The action and the spell read better apart in Turkish | approved |
| D071 | scout | İzci (background) / Gözcülük Yap (exploration action) | one term for both | Background noun vs exploration activity | approved |
| D072 | mug | Gasp (action) / Kupa (item) | one term for both | Verb vs object; `Kupa` is the vessel | approved |
| D073 | warrior | Cenkçi (bard muse) / Muharip (background) | one term for both | Muse is a performer archetype; background is a fighter | approved |

<!-- batch-proposals:start -->
## Batch proposals

Proposed while translating the batches. Same status values as above: agents use the
proposal while a row is `open`, and clearing or rejecting it regenerates the affected
overrides. Terms already settled above are not repeated.

| ID | Term | Proposal | Alternatives | Source | Status |
|---|---|---|---|---|---|
| D100 | a home in every port | Her Limanda Bir Ev | Her Limanda Bir Yuva | tr-pc2-feat-01 | approved |
| D101 | accompany | Eşlik Et | Refakat Et | tr-pc-feat-01 | approved |
| D102 | acolyte | Akolit | Çömez, Mürit | tr-pc-background-01 | approved |
| D103 | adapted cantrip | Uyarlanmış Kantrip | Uyumlu Kantrip, Uyarlanmış Temel Büyü | tr-pc-feat-01; cantrip aligns with Kantrip per GLOSSARY.md | approved |
| D104 | administer first aid | İlk Yardım Uygula | İlk Yardım Yap | tr-pc-action-01 | approved |
| D105 | agonizing rebuke | Kahredici Azarlama | Izdıraplı Azarlama | tr-pc2-feat-01 | approved |
| D106 | aiuvarin | Aiuvarin | — | tr-pc-versatileheritage-01 | approved |
| D107 | amnesiac | Hafıza Kaybı | Hafızasını Kaybetmiş, Amnezili | tr-pc2-background-01 | approved |
| D108 | analyze idiolect | Ağız Analizi | Şive Analizi, Bireysel Dil Analizi | tr-pc2-feat-01 | approved |
| D109 | anchor | Kök Sal | Demir At | tr-pc-action-01 | approved |
| D110 | ancient-blooded | Kadim Kanlı | Kadim Soylu | tr-pc-ancestry-01 | approved |
| D111 | animal skin | Hayvan Postu | Hayvan Derisi | tr-pc2-feat-01 | approved |
| D112 | anthem (bard compositions) | Marş (Cesaret Marşı, Toplanma Marşı) | İlahi, Ezgi | Owner says to keep subsequent composition-spell wording consistent with this Marş decision | approved |
| D113 | arcana (basic / advanced) | Mistik İlim | Arkana, Mistik Bilgi | tr-pc-archetype-01 | approved |
| D114 | assurance | Özgüven | Teminat, Garanti | tr-pc-feat-01 | approved |
| D115 | astrologer | Müneccim | Astrolog | tr-pc2-background-01 | approved |
| D116 | bane | Lanetle | Uğursuzluk, Bela | tr-pc-spell-01 | approved |
| D117 | barding | Koşum Zırhı | Binek Zırhı, At Zırhı | tr-pc-item-01 | approved |
| D118 | barreling charge | Bodoslama Hücum | Gülle Hücumu | tr-pc-feat-01 | approved |
| D119 | barrister | Dava Vekili | Avukat, Hukukçu | tr-pc-background-01 | approved |
| D120 | bastard sword | Melez Kılıç | Piç Kılıç, Bir Buçuk El Kılıç | tr-pc-item-01 | approved |
| D121 | blade brake | Kılıç Freni | Bıçak Freni | tr-pc-feat-01 | approved |
| D122 | blank slate | Boş Levha | Arınmış Zihin, Beyaz Sayfa | tr-pc-feat-01 | approved |
| D123 | boarding assault | Bordalama Saldırısı | Gemiye Baskın | tr-pc2-action-01 | approved |
| D124 | boneyard's call | Boneyard'ın Çağrısı | Kemikliğin Çağrısı | tr-pc2-feat-01 | approved |
| D125 | braggart (style) | Böbürlenen | Kibirbaz, Övüngen | tr-pc2-class-01 | approved |
| D126 | brandishing draw | Fiyakalı Kılıç Çekme | Çalımlı Çekiş | tr-pc2-feat-01 | approved |
| D127 | breadth (occult / divine / primal / arcane / patron's) | Enginlik | Genişlik, Kapsam | tr-pc-archetype-01 | approved |
| D128 | brine may / callow may / dream may | Tuzcul May / Toy May / Rüya Mayi | Tuz Kızı / Toy Kız / Düş Kızı | tr-pc-feat-01 | approved |
| D129 | buckler | Küçük Kalkan | Kolluk Kalkanı, Çıkıntılı Kalkan | tr-pc-item-01 | approved |
| D130 | burn it! | Yak Gitsin! | Yak Onu! | tr-pc-feat-01 | approved |
| D131 | cackle (witch hex) | Kıkırdama | Kahkaha, Katılma | tr-pc-spell-01 | approved |
| D132 | caltrops | Tuzak Dikenleri | Demir Dikenler, Mıhlar | tr-pc-item-01 | approved |
| D133 | canny acumen | Kurnaz Sezgi | Kıvrak Zekâ | tr-pc-feat-01 | approved |
| D134 | cant-fall-here | Burada Yıkılamazsın | Burada Düşemezsin | tr-pc2-feat-01 | approved |
| D135 | canticle / dirge / aria / etude | Kaside / Ağıt / Arya / Etüt | Şarkı, Ezgi | tr-pc-spell-01 | approved |
| D136 | cantorian reinforcement / rejuvenation / restoration | Cantorian Takviyesi / Gençleşmesi / Yenilenmesi | Kantoryan ... | tr-pc2-feat-01 | approved |
| D137 | cast a spell | Büyü Yap | Büyü Fırlat | Owner decision; overrides the earlier action wording | approved |
| D138 | catfolk | Kedisoy | Kedi Halkı, Kedimsi | tr-pc2-ancestry-01 | approved |
| D139 | changeling | Değişen | — | tr-pc-versatileheritage-01 | approved |
| D140 | charhide | Yanıkderi | Közderi | tr-pc-ancestry-01 | approved |
| D141 | cleanse affliction / cuisine | İlleti Temizle / Sofrayı Arındır | Zehir Temizle / Yiyecek Arındır | tr-pc-spell-01 | approved |
| D142 | clinging shadows initiate | Yapışkan Gölgeler Müridi | Tutunan Gölgeler Müridi | tr-pc2-feat-01 | approved |
| D143 | cloistered cleric | Manastır Rahibi | Keşiş Rahip | tr-pc-class-01 | approved |
| D144 | composition spells | Marş Büyüleri | Beste Büyüleri, Besteleme Büyüleri | Keep consistent with the owner-cleared Marş decision in D112 | approved |
| D145 | confabulator | Usta Masalcı | Lafbaz, Yalancı | tr-pc-feat-01 | approved |
| D146 | crossbow ace | Tatar Yayı Ası | Arbalet Ası | tr-pc-feat-01 | approved |
| D147 | crunch | Kemik Çatırtısı | Çıtırdat, Kemiren Çene | tr-pc2-feat-01 | approved |
| D148 | death warden | Ölüm Muhafızı | Ölüm Bekçisi | tr-pc-ancestry-01 | approved |
| D149 | dedication (archetype entry feat) | Yol; [class/archetype] Yolu | Bağlılık, Adanmışlık | Owner prefers Yol; e.g. Fighter Dedication = Savaşçı Yolu | approved |
| D150 | deliberate death | Bilinçli Ölüm | Kasıtlı Ölüm | tr-pc2-feat-01 | approved |
| D151 | dhampir | Dampir | Dhampir | tr-pc2-versatileheritage-01 | approved |
| D152 | didactic strike | Öğretici Vuruş | Didaktik Vuruş, Öğretici Saldırı | tr-pc2-feat-01; Strike aligns with Vuruş per GLOSSARY.md | approved |
| D153 | diehard | Zor Ölür | İnatçı Can | tr-pc-feat-01 | open |
| D154 | diverse weapon expert | Çeşitli Silah Uzmanı | Farklı Silah Uzmanı | tr-pc-archetype-01 | approved |
| D155 | divine font | İlahi Pınar | İlahi Kaynak, Kutsal Çeşme | tr-pc-class-01 | open |
| D156 | domain | Alan | Etki Alanı, Ruhban Alanı | tr-pc-domain-01 | open |
| D157 | dragonblood | Ejderkan | Ejder Kök, Ejderkanlı | tr-pc2-versatileheritage-01 | open |
| D158 | dromaar | Dromaar | — | tr-pc-versatileheritage-01 | approved |
| D159 | druidic order | Druidik Düzen | Druid Düzeni, Druid Tarikatı | tr-pc-class-01 | open |
| D160 | duskwalker | Alacakaranlık Gezgini | Alacagezen | tr-pc2-versatileheritage-01 | open |
| D161 | earworm | Kulağa Takılan Melodi | Dil Çerezi, Kulak Kurdu | tr-pc-feat-01 | approved |
| D162 | eat fortune | Talihi Ye | Şansı Yut | tr-pc2-feat-01 | open |
| D163 | eldritch | Mistik | Tekinsiz, Kadim | tr-pc2-action-01 | open |
| D164 | elfbane | Elfkıran | Elf Felaketi, Elf Belası | tr-pc2-ancestry-01 | approved |
| D165 | feint | Yanıltıcı Hamle | Fint Yap | tr-pc-action-01 | open |
| D166 | felling shot / felling strike | Düşüren Atış / Düşüren Vuruş | Yere İndiren, Düşüren Saldırı | tr-pc-feat-01; Strike aligns with Vuruş per GLOSSARY.md | open |
| D167 | feybound | Peri Bağlısı | Peri Bağımlısı, Periye Bağlı | tr-pc2-background-01 | approved |
| D168 | finisher | Bitirici Hamle | Bitirici | tr-pc2-action-01, tr-pc2-class-01 | open |
| D169 | flail / war flail | Zincirli Gürz / Savaş Dövgeni | Dövgen / Savaş Flaylı | tr-pc-item-01 | open |
| D170 | flair | Fiyaka | Çalım, Hava | tr-pc2-class-01 | open |
| D171 | flurry of blows | Darbe Yaylımı | Vuruş Sağanağı, Çifte Darbe | tr-pc2-class-01 | open |
| D172 | folksy patter | Halk Ağzı Lafazanlık | Halk Deyişleri | tr-pc-feat-02 | open |
| D173 | force (magical force in spells: force barrage, force bolt) | Güç (Güç Barajı, Güç Oku) | Kuvvet | tr-pc-spell-01 | open |
| D174 | form (battle forms) | Form / Formu (Uçan Form, Hayvan Formu, Dinozor Formu, Elementel Form, vb.) | Biçim, Şekil | tr-pc-spell-01 | open |
| D175 | fury instinct | Gazap İçgüdüsü | Hiddet İçgüdüsü, Öfke İçgüdüsü | tr-pc2-class-01 | open |
| D176 | glad-hand | Güler Yüzlü Tanışma | Sıcak Karşılama | tr-pc-feat-02 | approved |
| D177 | godbreaker | Tanrıkıran | İlah Kıran | tr-pc2-feat-01 | approved |
| D178 | greatclub | Tokaç | Büyük Sopa, Kalas | tr-pc-item-01 | approved |
| D179 | grimspawn / hellspawn | Kasvettohumu / Cehennemtohumu | Kasvetsoy / Cehennemsoy | tr-pc-feat-02 | open |
| D180 | harmonize self | Öz Uyum | Kendini Uyumla, Kendini Dengele, İçsel Ahenk | tr-pc2-feat-01, tr-pc2-spell-01 | open |
| D181 | haunted | Musallatlı | Musallat Olunmuş | tr-pc2-background-01 | open |
| D182 | herbalist | Aktar | Otacı, Şifacı | tr-pc-background-01 | open |
| D183 | hex spells | Nazar Büyüleri | Uğursuzluk Büyüleri, Heks Büyüleri | tr-pc-class-01 | approved |
| D184 | hillock halfling | Tepe Buçukluğu | Tümsek Buçukluğu | tr-pc-ancestry-01 | approved |
| D185 | hobnobber | Ayaküstü Sohbetçi | Ahbap Çavuş, Sohbetbaz | tr-pc-feat-02 | open |
| D186 | hold-scarred | Hisar Yaralı | Klan Yaralı, Yara İzli | tr-pc-ancestry-01 | open |
| D187 | hunter's trick (basic / advanced) | Avcı Numarası | Avcı Hilesi | tr-pc-archetype-01 | open |
| D188 | implausible purchase (investigator) | Akıl Almaz Tedarik (Müfettiş) | İnanılmaz Alışveriş | tr-pc2-feat-01 | open |
| D189 | indulgence | Haz Alanı | Zevk Alanı | tr-pc-domain-01 | open |
| D190 | irongut | Demirmide | Demir Karınlı | tr-pc-ancestry-01 | approved |
| D191 | item grades (lesser / moderate / greater) | Küçük / Orta / Gelişmiş | Basit / Orta / Büyük | tr-pc2-item-02 | open |
| D192 | item tier ladder (minor / lesser / moderate / greater / major / true) | (Ufak) / (Küçük) / (Orta) / (Büyük) / (Üstün) / (Hakiki) | (Minör) / (Zayıf) / (Orta) / (Gelişmiş) / (Majör) / (Gerçek) | tr-pc2-item-01 | open |
| D193 | jinx | Kem Göz | Uğursuzluk | tr-pc-action-01 | open |
| D194 | jungle catfolk | Cengel Kedisoyu | Vahşi Orman Kedisoyu | tr-pc2-ancestry-01 | approved |
| D195 | just one more thing | Bir Şey Daha Var | Son Bir Şey Daha | tr-pc2-feat-01 | approved |
| D196 | just the facts | Yalnızca Gerçekler | Sadece Olgular | tr-pc2-feat-01 | approved |
| D197 | kholo | Kholo | Gnoll | tr-pc2-ancestry-01 | open |
| D198 | kip up | Sıçrayıp Kalkma | Yay Gibi Fırlama | tr-pc-feat-02 | approved |
| D199 | land on your feet | Dört Ayak Üstüne Düşme | Ayaklarının Üstüne Düşme | tr-pc2-ancestry-01 | open |
| D200 | lawbringer | Yasa Getiren | Nizam Muhafızı | tr-pc-feat-02 | open |
| D201 | lay on hands | El Basma | Şifa Dokunuşu, Ellerle Şifa | tr-pc2-spell-01 | open |
| D202 | leech-clip | Sülük Kıskacı | Kaçak Kıskacı | tr-pc2-feat-02 | approved |
| D203 | left-hand / right-hand blood | Sol El Kanı / Sağ El Kanı | Sol Taraf Kanı | tr-pc2-feat-02 | open |
| D204 | liminal catfolk | Eşik Kedisoyu | Araf Kedisoyu | tr-pc2-ancestry-01 | approved |
| D205 | lizardfolk | Kertenkelesoy | Kertenkele Halkı | tr-pc2-ancestry-01 | open |
| D206 | lore (ancestry / class) | ... İlimi (Kholo İlimi, Kedisoy İlimi, Ejderha İlimi vb.) | ... Bilgisi, ... İlimi (Kobold İlimi, Tengu İlimi, Tripkee İlimi vb.) | tr-pc2-feat-01, tr-pc2-feat-02 | open |
| D207 | magpie snatch | Saksağan Kapması | Hırsız Kuş Kapması | tr-pc2-feat-02 | approved |
| D208 | make 'em sweat | Terlet | Ter Döktür | tr-pc2-feat-02 | approved |
| D209 | maneuver (basic / advanced) | Manevra | Hamle, Taktik | tr-pc-archetype-01 | open |
| D210 | martial disciple | Dövüş Sanatı Öğrencisi | Savaş Sanatı Çırağı, Dövüş Müriti | tr-pc-background-01 | approved |
| D211 | martyr | Fedaî | Şehit | tr-pc-feat-02 | approved |
| D212 | methodology | Metodoloji | Yöntem, İnceleme Yöntemi | tr-pc2-class-01 | open |
| D213 | might | Kudret Alanı | Güç Alanı | tr-pc-domain-01 | open |
| D214 | mutagen base names | Yırtıcı, Bilişsel, Ejderkalbi, Durdurulamaz, Cıva, Dingin, Gümüşdil Mutajeni | Canavarımsı, Zihinsel, Ejder Yüreği, Cuggernaut Mutajeni | tr-pc2-item-01 | open |
| D215 | natural poisons (belladonna / deathcap / hemlock / wolfsbane) | Güzelavrat Otu / Köygöçüren Tozu / Baldıran / Kurtboğan | Belladonna / Ölüm Şapkası / Su Baldıranı / Akonit | tr-pc2-item-01 | open |
| D216 | nephilim | Nephilim | — | D068 already approves keeping invented heritage names such as Nephilim in English | approved |
| D217 | once bitten | Bir Kez Isırılan | Sütten Ağzı Yanan | tr-pc2-action-01 | approved |
| D218 | panache paragon | Fiyaka Şahikası | Çalım Timzali | tr-pc2-feat-02 | approved |
| D219 | party crasher | Davetsiz Misafir | Parti Bozan | tr-pc2-feat-02 | approved |
| D220 | patron | Hami | Hamitanrı, Koruyucu, Koruyucu, Efendi | tr-pc-action-01, tr-pc-class-01 | open |
| D221 | patron's puppet | Haminin Kuklası | Veli Kuklası, Efendi Kuklası | tr-pc-spell-02 | approved |
| D222 | pick / light pick / greatpick | Kazma / Hafif Kazma / Büyük Kazma | Kazmaç, Gagalı Çekiç | tr-pc-item-01 | open |
| D223 | pilgrim | Hac Yolcusu | Hacı | tr-pc2-background-01 | open |
| D224 | pilgrim's token | Hac Yolcusu Nişanı | Hacı Yadigârı, Ziyaretçi Nişanı, Gezgin Nişanı | tr-pc2-feat-02, tr-pc2-item-01 | open |
| D225 | polymath (muse) | Hezarfen | Polimat, Çok Yönlü | tr-pc-class-01 | open |
| D226 | prairie rider | Bozkır Binicisi | Ova Binicisi | tr-pc-feat-02 | approved |
| D227 | predictable! | Tahmin Edilebilir! | Okunabilir! | tr-pc-feat-02 | approved |
| D228 | prescient planner / consumable | Öngörülü Plancı / Sarf Malzemesi | Basiretli Plancı | tr-pc-feat-02 | open |
| D229 | primal hierophant | Doğa Hiyerofantı | İlkel Hiyerofant | tr-pc-class-01 | approved |
| D230 | qi (qi blast, qi form, qi rush) | Qi (Qi Patlaması, Qi Formu, Qi Atılımı) | Çi, Ruh Enerjisi | tr-pc2-spell-01 | open |
| D231 | quick draw | Hızlı Çekiş | Hızlı Silah Çekme | tr-pc-feat-03 | approved |
| D232 | quietus strikes | Ebedi İstirahat Vuruşları | Sessizlik Vuruşları, Ebedi İstirahat Saldırıları | tr-pc2-feat-02; Strike aligns with Vuruş per GLOSSARY.md | approved |
| D233 | racket | Tezgâh | Dümen, Düzen, Şebeke | tr-pc-class-01 | open |
| D234 | rascal (style) | Hayta | Köftehor, Yaramaz | tr-pc2-class-01 | open |
| D235 | ratfolk | Sıçansoy | Sıçan Halkı, Ysoki | tr-pc2-ancestry-01 | open |
| D236 | razortooth | Usturadiş | Jiletdiş, Keskindir | tr-pc-ancestry-01 | open |
| D237 | razzle-dazzle | Göz Kamaştırma | Göz Boyama | tr-pc-feat-03 | approved |
| D238 | reactive striker | Reaktif Vurucu | Reaktif Saldırıcı, Reaktif Saldırgan | tr-pc-archetype-01; Strike aligns with Vuruş per GLOSSARY.md | approved |
| D239 | reconstruct the scene | Olay Yerini Canlandır | Mahalli Canlandır | tr-pc-feat-03 | approved |
| D240 | reposition | Yerinden Oynat | Konumlandır, Yeniden Konumlandır | tr-pc-action-01; aligns with GLOSSARY.md | approved |
| D241 | retributive strike | Misilleme Vuruşu | Cezalandırıcı Vuruş, Misilleme Saldırısı | tr-pc2-action-01; Strike aligns with Vuruş per GLOSSARY.md | approved |
| D242 | returned | Ölümden Dönen | Geri Dönen | tr-pc2-background-01 | open |
| D243 | riposte | ... Karşı Saldırısı (Fırsat Karşı Saldırısı, İmkânsız Karşı Saldırı vb.) | ... Karşı Darbesi | tr-pc2-feat-01 | open |
| D244 | root worker | Kök Şifacısı | Kök Hekimi | tr-pc2-background-01 | approved |
| D245 | ruffian (racket) | Zorba | Kabadayı, Hayta | tr-pc-class-01 | open |
| D246 | runtboss | Çelimsiz Başı | Bodur Başı, Çelimsiz Elebaşı | tr-pc2-ancestry-01 | open |
| D247 | runtsage | Çelimsiz Bilgesi | Bodur Bilgesi | tr-pc2-feat-02 | open |
| D248 | sap | Deri Cop | Cop, Kısa Cop | tr-pc-item-01 | open |
| D249 | sawtooth saber | Testerediş Kılıç | Testere Dişli Kılıç | tr-pc-item-01 | open |
| D250 | scare to death | Korkudan Öldür | Ödünü Patlat | tr-pc-feat-03 | approved |
| D251 | schadenfreude | Kötücül Sevinç | Schadenfreude, Zarara Sevinme | tr-pc2-spell-01 | approved |
| D252 | scholar | Akademisyen | Âlim, Bilgin | tr-pc-background-01 | open |
| D253 | seasoned | Güngörmüş | Ehil | tr-pc-feat-03 | approved |
| D254 | shadow's web | Gölge Ağı | Gölgenin Ağı, Gölge Örgüsü | tr-pc2-spell-01 | open |
| D255 | shinstabber | Kaval Kesen | İncik Bıçaklayan | tr-pc2-feat-02 | open |
| D256 | snare | Kapan | Tuzak | tr-pc2-item-01 | open |
| D257 | sneak attacker | Sinsi Saldırıcı | Sinsi Saldırgan | tr-pc-archetype-01 | approved |
| D258 | spellcaster (expert / master / legendary) | Büyücü | Büyü Fırlatıcı | Generic class-role term; distinct from the Sorcerer and Wizard classes | approved |
| D259 | squawk! | Gakla! | Ciyakla! | tr-pc2-feat-02 | approved |
| D260 | squire | Silahtar | Şövalye Çırağı, Yaver | tr-pc2-background-01 | approved |
| D261 | staff / wand | Asa / Değnek | Değnek / Çubuk | tr-pc2-item-01 | open |
| D262 | stance (clinging shadows stance, wild winds stance) | ... Duruşu (Yapışkan Gölgeler Duruşu, Vahşi Rüzgârlar Duruşu) | ... Tavrı, ... Hali | D055 already approves Duruş as the stance suffix | approved |
| D263 | starknife | Yıldızbıçak | Yıldız Bıçak, Dörtlü Bıçak | tr-pc-item-01 | open |
| D264 | sterling / superb (item grade) | Som / Harika | Kusursuz, Üstün | tr-pc-item-01 | open |
| D265 | straveika / svetocher | Straveika / Svetocher | — | tr-pc2-feat-02 | open |
| D266 | streetwise | Sokak Görmüş | Sokak Kurdu | tr-pc-feat-03 | open |
| D267 | summon <trait> | <Tür> Çağır (Peri Çağır, Hortlak Çağır, Celestial Çağır, Monitor Çağır, Fiend Çağır) | <Tür> Davet Et, <Tür> Getir | tr-pc-spell-02; Celestial, Monitor, Fiend kept in English per GLOSSARY.md (never Semavi / Gözlemci / İblis) | approved |
| D268 | superstition instinct | Hurafe İçgüdüsü | Batıl İnanç İçgüdüsü | tr-pc2-class-01 | open |
| D269 | switcheroo | Ters Köşe | Yer Değiştirme | tr-pc2-feat-02 | approved |
| D270 | tailwind | Pupa Rüzgârı | Arkadan Esen Rüzgâr, Kuyruk Rüzgârı | tr-pc-spell-02 | approved |
| D271 | tengu | Tengu | — | tr-pc2-ancestry-01 | open |
| D272 | tengu feather fan | Tengu Tüy Yelpazesi | Tengu Yelpazesi | tr-pc2-feat-02 | open |
| D273 | tengu feather fan / tengu gale blade | Tengu Tüy Yelpazesi / Tengu Fırtına Kılıcı | Tengu Kanat Yelpazesi / Tengu Bora Kılıcı | tr-pc2-item-01 | open |
| D274 | that's odd | Bu İşte Bir Tuhaflık Var | Tuhaf Bir Durum | tr-pc2-feat-02 | open |
| D275 | the bigger they are | Ne Kadar Büyük Olurlarsa | Ne Kadar Cüsseli | tr-pc2-feat-02 | approved |
| D276 | the harder they fall | Düşüşü Sert Olur | Sert Çakılış | tr-pc-feat-03 | approved |
| D277 | theses / thesis | Tez | Araştırma Tezi | tr-pc-class-01 | open |
| D278 | thief (racket) | Yankesici | Hırsız | tr-pc-class-01 | open |
| D279 | thunderstrike | Yıldırım Çarpması | Şimşek Vuruşu, Gök Gürültüsü Darbesi | tr-pc-spell-02 | open |
| D280 | titan wrestler | Titan Güreşçisi | Dev Güreşçisi | tr-pc-feat-03 | approved |
| D281 | toolkit | Alet Takımı | Alet Çantası, Alet Kiti | tr-pc-item-01 | open |
| D282 | translocate | Yer Değiştir | Işınlan, Mekân Değiştir | tr-pc-spell-02 | open |
| D283 | travel | Yolculuk Alanı | Seyahat Alanı | tr-pc-domain-01 | open |
| D284 | trick magic item | Büyülü Eşyayı Kandır | Eşyayı Aldat | tr-pc-feat-03 | approved |
| D285 | trickery (basic / advanced) | Hilekârlık | Düzenbazlık, Kurnazlık | tr-pc-archetype-01 | open |
| D286 | trip | Çelme Tak | Çelmeleme | tr-pc-action-01 | open |
| D287 | tripkee | Tripkee | Grippli | tr-pc2-ancestry-01 | open |
| D288 | tumble through | Sıyrılıp Geç | Arasından Sıyrıl, Arasından Yuvarlan | tr-pc-action-01; aligns with GLOSSARY.md | approved |
| D289 | uncanny dodge | Olağanüstü Sıyrılma | Tekinsiz Kaçınma, Doğaüstü Sıyrılma | tr-pc-archetype-01 | approved |
| D290 | undeath | Hortlaklık Alanı | Yaşayan Ölüler Alanı | tr-pc-domain-01 | open |
| D291 | untamed form / shift | Ehlileşmemiş Form / Ehlileşmemiş Dönüşüm | Vahşi Form, Yabani Form | tr-pc-spell-02 | open |
| D292 | untamed order | Ehlileşmemiş Düzen | Vahşi Düzen, Yabani Düzen | tr-pc-class-01; associated strikes align with Vuruş per GLOSSARY.md | open |
| D293 | upstage | Rol Çal | Gölgede Bırak | tr-pc2-action-01 | approved |
| D294 | vandal | Vandal | Tahripkâr | tr-pc-feat-03 | approved |
| D295 | vicious evisceration | Vahşi Deşme | Gaddar Deşme | tr-pc2-feat-02 | approved |
| D296 | vomit stomach | Mide Çıkarma | Mide Kusma | tr-pc2-feat-03 | approved |
| D297 | wall of ... | ... Duvarı / Taş Duvar (Ateş Duvarı, Güç Duvarı, Buz Duvarı, Taş Duvar, Diken Duvarı, Rüzgâr Duvarı) | ... Seddi, ... Barikatı | tr-pc-spell-02 | open |
| D298 | wand | Değnek | Asa | tr-pc2-item-02 | open |
| D299 | wand of overflowing life | Taşan Yaşam Değneği | Taşkın Yaşam Değneği, Taşan Hayat Değneği | tr-pc2-item-02 | open |
| D300 | wand of slaughter | Kıyım Değneği | Katliam Değneği | tr-pc2-item-02 | open |
| D301 | wand of smoldering fireballs | Tüten Ateş Topları Değneği | Közlenen Ateş Topları Değneği, İçten Yanan Ateş Topları Değneği | tr-pc2-item-02 | open |
| D302 | wand of the snowfields | Kar Ovaları Değneği | Kar Düzlükleri Değneği, Kar Kırları Değneği | tr-pc2-item-02 | open |
| D303 | wand of the spider | Örümcek Değneği | Örümcek Ağı Değneği | tr-pc2-item-02 | open |
| D304 | wand rank qualification ((Xth-rank spell)) | (X. Derece Büyü) | (Kademe X Büyü) | tr-pc2-item-01 | open |
| D305 | ward | Vesayetli | Himaye Altındaki | tr-pc2-background-01 | open |
| D306 | ward medic | Koğuş Hekimi | Toplu Hekim | tr-pc-feat-03 | approved |
| D307 | warleader's bulwark | Savaş Lideri Siperi | Savaş Efendisi Siperi, Savaş Lideri Göğüslüğü | tr-pc2-item-02 | open |
| D308 | warpriest | Savaş Rahibi | Cenk Rahibi | tr-pc-class-01 | open |
| D309 | warrior (muse) | Cenkçi | Savaşçı, Muharip | D073 already approves Cenkçi for Warrior (Muse), distinct from Muharip (background) | approved |
| D310 | whip claw | Kamçı Pençe | Kamçılı Pençe | tr-pc2-item-02 | approved |
| D311 | whodunnit? | Katil Kim? | Fail Kim? | tr-pc2-feat-03 | approved |
| D312 | wild winds gust / initiate | Vahşi Rüzgârlar Esintisi / Müridi | Deli Rüzgârlar ... | tr-pc2-feat-03 | open |
| D313 | wilding (basic / advanced) | Yabanilik | Yaban Yaşamı, Doğallık | tr-pc-archetype-01 | open |
| D314 | wildwood | Yabanorman | Vahşi Orman | tr-pc-ancestry-01 | approved |
| D315 | wind jump | Rüzgâr Sıçrayışı | Rüzgâr Atlayışı | tr-pc2-feat-03 | open |
| D316 | winglets / winglet flight | Kanatçıklar / Kanatçık Uçuşu | Küçük Kanatlar | tr-pc2-feat-03 | open |
| D317 | witch's charge | Witch'in Himayesi | Cadının Himayesi, Cadının Emaneti | tr-pc-feat-04 | approved |
| D318 | witch's hut | Witch Kulübesi | Cadı Kulübesi, Baba Yaga Kulübesi | tr-pc-feat-04 | approved |
| D319 | witchcraft (basic / advanced) | Witch Sanatı | Cadılık, Cadı Sanatı | tr-pc-archetype-01 | approved |
| D320 | witchwarg elixir | Cadı Vargı İksiri | Cadıvarg İksiri, Witchwarg İksiri | tr-pc2-item-02 | open |
| D321 | wolf drag | Kurt Sürüklemesi | Kurt Çekişi | tr-pc2-feat-03 | approved |
| D322 | wolfsbane | Kurtboğan | Kurtboğan Otu | tr-pc2-item-02 | approved |
| D323 | wyvern poison | Wyvern Zehri | Vayvırn Zehri | tr-pc2-item-02 | approved |
| D324 | you're next | Sıradaki Sensin | Sıra Sende | tr-pc-feat-04 | approved |
| D325 | zeal | Şevk Alanı | Gayret Alanı, Taassup Alanı | tr-pc-domain-01 | open |
| D326 | zealous rush | Şevkli Hücum | Gayretli Hücum | tr-pc-feat-04 | approved |

<!-- batch-proposals:end -->
