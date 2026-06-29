# Multi-language expansion — sourcing checklist

> Companion to `AUDIO-SOURCING-GUIDE.md`. The app's data spine is **already N-language**
> (`Languages.json` registry + code-keyed catalog; see the `evolve/multilang-expansion`
> work). Adding a language is a **content** job, not a code job. This doc is the worksheet
> a human uses to source authentic content — Claude will **not** fabricate audio, lyrics,
> or translations (wrong tones / machine translation = inauthentic, violates Principle 4).

## Hard requirements before a language ships (enforced by `scripts/catalog_integrity.py`)

For **every** song you add a language `code` to, you MUST provide all of:
1. **Real audio** — a genuine native recording (not TTS), trimmed + normalized to −16 LUFS per the pipeline, placed under `TreVoci/Resources/Audio/<subdir>/`.
2. **Correct title** in that language (`titles[code]`).
3. **Timestamped lyrics** (`lyrics[code]`) — ≥1 line, non-decreasing times, last time ≤ duration.
4. **A credited source** (`recordingSource[code]`) — where the recording came from. No anonymous recordings.
5. For non-Latin/`isRomanizable` languages: **verified** romanization on every lyric line (warning today; never fabricate).

A registered language with **no** songs yet is fine — it shows an honest "coming soon" everywhere and is non-selectable. Add songs incrementally.

## Recommended rollout phases

- **Phase 1 (Latin script, drop-in — no code work):** 🇫🇷 French, 🇪🇸 Spanish, 🇩🇪 German. Nunito renders them; highest overlap with our existing melodies. **French first** — Frère Jacques & Twinkle are French in origin.
- **Phase 1b:** 🇵🇹 Portuguese (huge reach, same ease).
- **Phase 2 (needs the PARKED RTL + non-Latin font work):** 🇸🇦 Arabic, then Hindi / Japanese / Korean / Russian. Nunito is Latin-only; Arabic is RTL with a regional rhyme canon — a real technical lift, not a data edit.

---

## A) Cross-cultural melodies — which of our 8 carry over, with the authentic native title

Use the **real, well-known** version in each language — never a literal translation of the English.

| Song id | 🇫🇷 French (Comptine) | 🇪🇸 Spanish | 🇩🇪 German | 🇸🇦 Arabic |
|---|---|---|---|---|
| `frere-jacques` | **Frère Jacques** (native) | Martinillo / Campanero | Bruder Jakob | ~ (regional) |
| `twinkle` | **Ah ! vous dirai-je, Maman** / Brille brille | Estrellita / Brilla brilla estrellita | Funkel, funkel, kleiner Stern | نجمة نجمة |
| `old-macdonald` | Dans la ferme de Mathurin | El viejo MacDonald tenía una granja | Onkel Jörg hat einen Bauernhof | — |
| `if-youre-happy` | Si tu aimes le soleil (frappe des mains) | Si eres feliz y lo sabes | Wenn du glücklich bist | ~ |
| `head-shoulders` | Tête, épaules, genoux, pieds | Cabeza, hombros, rodillas, pies | Kopf, Schulter, Knie und Fuß | — |
| `happy-birthday` | Joyeux anniversaire | Cumpleaños feliz / Feliz cumpleaños | Zum Geburtstag viel Glück | **سنة حلوة يا جميل** (a *different*, native birthday song — use it, don't translate) |
| `row-your-boat` | ✗ no native twin | ✗ | ✗ | ✗ |
| `abc-song` | Alphabet en chantant (own letters) | Canción del abecedario (own letters) | ABC-Lied (ß, umlauts) | ✗ different script |

Notes:
- **`row-your-boat` is an English round** — it has no authentic equivalent. Do NOT add fr/es/de to it; leave it English-only.
- **`abc-song`**: each language sings ITS OWN alphabet to the Twinkle melody — different letters/lyrics, still authentic. Treat as a per-language re-author, not a translation.
- **`happy-birthday`** in Arabic is culturally a *different* song (سنة حلوة يا جميل) — a feature, not a problem.

## B) Each language's OWN canon (the richer, more authentic contribution)

These have no cross-language twins; they're what makes each language a real "voice," like our Stella Stellina / 拔萝卜. Source 3–4 public-domain/traditional ones per language:

- **🇫🇷 French:** Au clair de la lune · Alouette · Sur le pont d'Avignon · Une souris verte · Ainsi font font font.
- **🇪🇸 Spanish:** Los pollitos dicen · Pin Pon · La vaca lechera · Debajo de un botón · Arroz con leche.
- **🇩🇪 German:** Alle meine Entchen · Backe backe Kuchen · Hänschen klein · Der Kuckuck und der Esel.
- **🇸🇦 Arabic:** سنة حلوة يا جميل · regional Levantine/Egyptian/Gulf rhymes (decide the target dialect first — the canon is regional).

## C) Where verified content comes from (the sourcing path)

- **Audio:** prefer the same kind of trusted kids'-content channels we already credit — e.g. French: *Comptines et chansons*, *Monde des Titounis*; Spanish: *Super Simple Español*, *El Reino Infantil*; German: *Sing mit mir Kinderlieder*. Confirm reuse rights / licensing before bundling. Most melodies are public-domain, but a specific *recording* is not.
- **Lyrics + timing:** transcribe from the chosen recording (see `whisper-transcription-gotchas` memory), then hand-correct. Romanization (Arabic/CJK) must be verified by a native speaker.
- **Pipeline:** `AUDIO-SOURCING-GUIDE.md` (yt-dlp → ffmpeg trim → ffmpeg-normalize → fade → install under `Resources/Audio/<lang>/` for culture-specific, `Audio/cross-cultural/` for shared).
- **Naming:** cross-cultural = `{song-id}-{lang}.m4a`; culture-specific = `{song-id}.m4a`.

## D) Per-song authoring checklist (copy per song × language)

```
[ ] song: __________   language: ___
[ ] authentic native title confirmed (not a translation)   →  titles[code]
[ ] real recording sourced + licensed                       →  Audio/...
[ ] trimmed, −16 LUFS, faded                                →  pipeline
[ ] lyrics transcribed + hand-corrected, timestamps set      →  lyrics[code]
[ ] romanization (if non-Latin) verified by native speaker
[ ] recordingSource credited                                 →  recordingSource[code]
[ ] category set (cross-cultural → "cross-cultural"; native → the language code)
[ ] python3 scripts/catalog_integrity.py  → green
```
