---
name: Tre Voci
description: Audio-first trilingual nursery rhyme app for iOS — warm, calm, quietly premium.
colors:
  bark: "#3A3028"
  stone: "#8B7E6E"
  mist: "#B8ADA0"
  cream: "#FBF8F1"
  warm: "#F5F0E6"
  sand: "#E8E0D0"
  coral: "#FF7B6B"
  rose: "#FF6B8A"
  peach: "#FFAD8F"
  gold: "#FFB84D"
  plum: "#9B59B6"
  italian-green: "#2A6B45"
  italian-bg: "#EDF5F0"
  chinese-red: "#C43B3B"
  chinese-bg: "#FDF0F0"
  english-blue: "#2D5BA9"
  english-bg: "#EDF2FA"
typography:
  display:
    fontFamily: "Nunito, system-ui"
    fontSize: "26pt"
    fontWeight: 900
    lineHeight: 1.1
  headline:
    fontFamily: "Nunito, system-ui"
    fontSize: "22pt"
    fontWeight: 900
    lineHeight: 1.15
  title:
    fontFamily: "Nunito, system-ui"
    fontSize: "17pt"
    fontWeight: 900
    lineHeight: 1.2
  body:
    fontFamily: "Nunito, system-ui"
    fontSize: "16pt"
    fontWeight: 600
    lineHeight: 1.35
  label:
    fontFamily: "Nunito, system-ui"
    fontSize: "13pt"
    fontWeight: 600
    lineHeight: 1.3
rounded:
  sm: "12pt"
  md: "20pt"
  lg: "28pt"
  pill: "999pt"
spacing:
  xs: "4pt"
  sm: "8pt"
  md: "12pt"
  lg: "16pt"
  xl: "20pt"
  xxl: "24pt"
  control-row: "40pt"
components:
  button-primary:
    backgroundColor: "#FFFFFF"
    textColor: "{colors.bark}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "12pt 24pt"
    height: "44pt"
  chip-language-italian:
    backgroundColor: "{colors.italian-bg}"
    textColor: "{colors.italian-green}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "8pt 16pt"
  chip-language-chinese:
    backgroundColor: "{colors.chinese-bg}"
    textColor: "{colors.chinese-red}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "8pt 16pt"
  chip-language-english:
    backgroundColor: "{colors.english-bg}"
    textColor: "{colors.english-blue}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "8pt 16pt"
  card-song:
    backgroundColor: "{colors.coral}"
    textColor: "#FFFFFF"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    padding: "20pt"
---

# Design System: Tre Voci

## 1. Overview

**Creative North Star: "The Family Kitchen Table"**

Three languages, three cultures, gathered around one shared melody — the same tune sung as "Fra Martino Campanaro," "两只老虎," and "Are You Sleeping" in the same three minutes. The visual system exists to make that gathering feel warm and physical, like a well-loved illustrated songbook left on the kitchen table, not like software. Cream paper, toasted-bark ink, soft coral warmth, and three deliberate language colors (Forest Basil, Lacquer Red, Denim Blue) that never wander from their meaning. Nothing glossy, nothing synthetic, nothing that competes for a toddler's — or a tired parent's — attention for longer than it takes to tap play.

This system explicitly rejects the generic edtech/kids-app look (bright primary colors, cartoon mascots, badge-and-streak gamification pressure), the cold-minimalist-SaaS look (sterile gray-on-white dashboards with no warmth), and anything screen-hungry or attention-grabby (autoplay-into-next, infinite scroll, notification nudges). Every surface should read as calm enough to open, glance at, and put down.

**Key Characteristics:**
- Warm cream/paper base with toasted-bark ink — never SaaS-white, never cold gray
- Three named, consistent language colors that carry meaning, never used decoratively
- Soft ambient glow (colored, diffuse shadows), not hard drop-shadows or flat cards
- Tactile-confident rounded shapes: capsule pills for actions, generously rounded cards
- Gentle, non-alarming motion — breathing pulses and springs, always reduce-motion-safe

## 2. Colors

The palette reads as a warm, sun-through-linen paper world punctuated by one confident coral accent and three unmistakable language colors — never a cold neutral, never a saturated primary-color toy palette.

### Primary
- **Sunset Coral** (#FF7B6B): the single brand accent — AccentColor, primary CTAs, Daily Mix hero gradient, the app's one moment of real color commitment. Used deliberately, not everywhere.

### Secondary
- **Dawn Rose** (#FF6B8A), **Golden Honey** (#FFB84D), **Soft Peach** (#FFAD8F), **Twilight Plum** (#9B59B6): the gradient-accent family used on song and Daily Mix card backgrounds (per-song gradients drawn from this set, layered under a `black @ 0.32` scrim for text legibility). Never used as flat single-color fills — they exist to build gradients, not to stand alone as UI chrome color.

### Neutral
- **Warm Milk Paper** (#FBF8F1): primary app background.
- **Soft Linen** (#F5F0E6): secondary surface (e.g. the speaker/AirPlay pill).
- **Sandstone** (#E8E0D0): tertiary/muted surface.
- **Toasted Espresso Bark** (#3A3028): primary text — near-black brown, never true black.
- **Weathered Stone** (#8B7E6E): secondary text.
- **Morning Mist** (#B8ADA0): tertiary/disabled text, icon fills.

### Named Rules
**The Kitchen Table Rule.** Sunset Coral is the only color allowed to act as a flat, standalone brand accent. Everything else in the accent family (Rose, Honey, Peach, Plum) exists only inside gradients — never as a solid fill on its own.

**The Language Fidelity Rule.** Forest Basil, Lacquer Red, and Denim Blue are never repurposed for anything other than their own language. If a surface needs a fourth accent color for something unrelated to Italian, Mandarin, or English, it must come from the Secondary gradient family — not from the language set.

### Language Roles

The tri-language identity is a fourth, dedicated color role — not folded into Primary/Secondary/Neutral because it carries product meaning, not decoration:

- **Forest Basil** (#2A6B45) on **Sage Mist Background** (#EDF5F0): Italian.
- **Lacquer Red** (#C43B3B) on **Blush Paper Background** (#FDF0F0): Mandarin Chinese.
- **Denim Blue** (#2D5BA9) on **Powder Sky Background** (#EDF2FA): English.

Each pairs a saturated language color with its own tinted-neutral background, used consistently for that language's chips, progress segments, and section headers across every screen.

## 3. Typography

**Display/Body Font:** Nunito (variable font, weights extraLight → black), with the system font as fallback.
**Non-Latin Fallback:** Chinese lyric text renders in the system font at a matched weight — Nunito has no CJK glyph coverage, and forcing it would silently fall back mid-string.

**Character:** One warm, rounded humanist sans carried across every weight — from `.black` screen titles to `.semiBold` captions — so hierarchy comes from weight and size, not from mixing families. Nothing sharp, nothing condensed, nothing that reads as "system default."

### Hierarchy
- **Display** (`.black`, 26pt, line-height 1.1): screen-level titles (Home, Player).
- **Headline** (`.black`, 22pt, line-height 1.15): secondary screen titles, Session Complete.
- **Title** (`.black`, 17pt, line-height 1.2): section headers (CultureSection, card titles).
- **Body** (`.semiBold`/`.bold`, 14–16pt, line-height 1.35): body copy, lyrics, parent-facing explanatory text. Uses `Font.nunito(relativeTo:)` for Dynamic Type wherever legibility matters.
- **Label** (`.semiBold`/`.bold`, 11–13pt, letter-spacing default): captions, metadata, chip text, timestamps.

### Named Rules
**The One-Family Rule.** Every weight from extraLight to black comes from Nunito. Hierarchy is built by pairing weight + size, never by introducing a second typeface.

## 4. Elevation

Depth is a soft, colored ambient glow, not a hard drop-shadow or flat tonal layering. Gradient cards sit above the cream background with a diffuse, tinted shadow that picks up the card's own hue (a coral card casts a soft coral glow, not a generic black shadow), reinforcing warmth instead of adding visual weight. Translucent decorative circles (`white @ 0.06–0.08`) layered inside hero cards add texture without adding contrast noise.

### Shadow Vocabulary
- **Card glow** (`color: <card's own accent> @ 0.25 opacity, radius: 16pt, y: 8pt`): the default elevation for song cards, Daily Mix hero, and any gradient-filled surface. The shadow color always matches the card's dominant hue — never a neutral black.
- **Texture circle** (`white @ 0.06–0.08 fill, no shadow`): decorative background interest inside hero/gradient cards, not a depth cue.

### Named Rules
**The Colored Glow Rule.** Shadows are never neutral gray or black in this system. Every shadow inherits the hue of the surface casting it.

## 5. Components

Every interactive element carries tactile confidence: generously rounded, warm-toned, and weighted enough (via its colored glow) to feel deliberate rather than plush or toy-like.

### Buttons
- **Shape:** capsule (`rounded: 999pt`, fully rounded ends).
- **Primary:** white capsule pill sitting on top of a gradient card (`backgroundColor: #FFFFFF`, `textColor: bark`), min 44×44pt tap target, `.buttonStyle(.plain)`.
- **States:** no hover on iOS; press states use the system's default scale/opacity feedback plus `.accessibilityAddTraits(.isButton)` and an explicit `.accessibilityLabel` on every instance.

### Chips (Language Pills)
- **Style:** capsule shape, tinted background + saturated text in the matching language pair (Sage Mist bg / Forest Basil text for Italian, and so on).
- **State:** selected vs. unselected toggles between the tinted-background pair and a neutral (Sandstone/Weathered Stone) unselected state.

### Cards / Containers
- **Corner Style:** large rounding (`rounded: 20–28pt`) — song cards and the Daily Mix hero card are the most rounded surfaces in the system.
- **Background:** per-song gradient drawn from the Secondary accent family, always under a `black @ 0.32` scrim for text legibility.
- **Shadow Strategy:** Card glow (see Elevation) — colored, never neutral.
- **Internal Padding:** 16–24pt.
- **Sizing:** adapts by `horizontalSizeClass` — 160×190pt compact (iPhone), 220×250pt regular (iPad) — via `readableContentWidth(_:)`, capping content at 640–720pt and centering on iPad/landscape rather than stretching edge-to-edge.

### Progress / Tri-color Bar
- **Style:** segmented progress indicator, one segment per language in that language's own color, reflecting the sequential IT→ZH→EN playback structure. The tri-color segmentation is a signature, product-meaningful component — never simplify it to a single flat progress color.

### Navigation
- No `NavigationStack` at the root; screen flow is enum-based (`FlowState`) with sheet-style transitions (Splash → Onboarding → Home → Player → Activity Bridge → Session Complete). Transitions use spring animation (`response: 0.4, dampingFraction: 0.8`), always gated behind `@Environment(\.accessibilityReduceMotion)`.

### Player Emoji Pulse (signature component)
A gentle "breathing" scale pulse (`scaleEffect(1.08)`, `.easeInOut(duration: 2.5).repeatForever`) on the Player's song emoji — the system's one piece of ambient, idle motion, deliberately slow and non-alarming, and disabled under reduce-motion.

## 6. Do's and Don'ts

### Do:
- **Do** keep Sunset Coral as the only flat, standalone brand color; everything else in the accent family lives inside gradients only.
- **Do** keep the three language colors (Forest Basil, Lacquer Red, Denim Blue) fixed to their own language across every surface — chips, progress segments, section headers.
- **Do** use colored, hue-matched ambient shadows for elevation; never a neutral black/gray drop-shadow.
- **Do** cap body copy at 65–75 characters per line and use `Font.nunito(relativeTo:)` for parent-facing text so Dynamic Type holds.
- **Do** gate every animation behind `accessibilityReduceMotion`, with a crossfade or instant-transition fallback.
- **Do** aim for AAA-leaning contrast, not just the WCAG AA baseline — this app gets used by a tired parent, one thumb, in a dim room at bedtime.

### Don't:
- **Don't** introduce bright, saturated "toy" primary colors, cartoon mascots, or badge/streak gamification pressure — that's the generic edtech/kids-app look this system explicitly rejects.
- **Don't** flatten this into a cold minimalist SaaS dashboard (sterile gray-on-white, no warmth) — warmth is load-bearing here, not decorative.
- **Don't** add anything screen-hungry or attention-grabby: no autoplay-into-next, no infinite scroll, no notification nudges. The app's whole philosophy is "get the parent back to the room."
- **Don't** use a `border-left`/`border-right` colored stripe as an accent on any card, list row, or callout — rewrite with a full border, a background tint, or a leading icon instead.
- **Don't** use gradient text (`background-clip: text` + gradient). Emphasis comes from Nunito's weight range, not text-fill tricks.
- **Don't** reach for glassmorphism/blur-as-decoration by default — it isn't in this system today, and it should stay rare and purposeful if it's ever used at all.
- **Don't** let the song-card grid go uniform (identical size/shape/icon-heading-text repeated with no variation) — the existing `horizontalSizeClass`-adaptive sizing and per-song gradients are what keep the grid from reading as generated.
- **Don't** put a tiny uppercase tracked "eyebrow" label above every section header (CultureSection, Parent Zone) — it's 2023-era AI scaffolding, not this system's voice.
