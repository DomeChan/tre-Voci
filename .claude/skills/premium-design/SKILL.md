---
name: premium-design
description: Apple-Design-Award-caliber polish pass on a Tre Voci screen. Runs a strict Audit → Plan → Implement → Gate → Commit loop with pixel-level verification and failure-prevention contracts. Triggers on "premium design pass", "design polish", "premium polish", or any request to improve a screen to ADA-level quality.
---

# Premium Design — Tre Voci Polish Skill

Orchestrator-driven loop: **AUDIT → PLAN → IMPLEMENT → GATE → COMMIT**

You are the orchestrator. Workers implement. You review pixels, gate, and commit. Never let a worker commit.

Tre Voci is a SwiftUI, zero-dependency, iOS 17+ app for a 2-year-old. Polish here means **warm, calm, oversized-tap-target, parent-trustworthy** — not flashy. Every change must survive a toddler's hands and a parent's eye.

## Parameters

Parse from user input:

| Parameter | Values | Default |
|-----------|--------|---------|
| surface | home, player, onboarding, splash, parentzone, activity, settings, donation | required |
| device | iphone, ipad, both | iphone |

**Tre Voci is light-only by design** — there is no dark variant. The app uses a fixed custom palette (`Color+Theme.swift`), so there is no `mode` parameter. Audit and gate against the tokens, never against system dark colors.

---

## Reference Library — Mobbin MCP (sets the target)

The "Target" column in this skill is grounded in best-in-class real apps, **not taste**. It depends on the **Mobbin MCP** (Pro plan). One-time setup:

```bash
claude mcp add mobbin --scope user --transport http https://api.mobbin.com/mcp
# first call opens a browser for OAuth — no API key, no token to manage
```

Before auditing, map the surface to a Mobbin search and pull 3–5 references (search apps → open the matching flow → grab the screens):

| Surface | Mobbin search |
|---------|---------------|
| home | kids & education, music/playback home, audio libraries |
| player | music players, audio playback, now-playing |
| onboarding | onboarding flows, kids onboarding, name/profile setup |
| parentzone / settings | parental controls, account & settings, kids parent gate |
| activity | kids activity, gamified learning, progress/stats |
| donation | tip jar, support the developer, indie app donation, StoreKit purchase sheet |

These references set the bar for the Findings Table (Phase 0) and the acceptance criteria (Phase 1). If the MCP is unreachable, say so and fall back to taste — do not silently skip the reference pass.

---

## Phase 0: Surface Audit (ALWAYS FIRST — no exceptions)

**Before writing a single line of spec**, capture the live surface and inventory every element. In parallel, pull the Mobbin references for this surface (see Reference Library above) — you audit the current surface *against* real references, not in a vacuum.

**Preferred path — XcodeBuildMCP** (defaults already wired: project `TreVoci.xcodeproj`, scheme `TreVoci`, sim `iPhone Air`, bundleId `com.trevoci.app`):

```
mcp__xcodebuildmcp__build_run_sim {}          # boots sim, installs, launches
mcp__xcodebuildmcp__screenshot { returnFormat: "path" }   # capture PNG
mcp__xcodebuildmcp__snapshot_ui {}            # semantic element tree (elementRef + text)
```

Shell fallback:
```bash
xcodebuild -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air' build
UDID=$(xcrun simctl list devices booted | grep -o '[0-9A-F-]\{36\}' | head -1)
xcrun simctl io "$UDID" screenshot /tmp/pd-audit.png
```

Capture **light only** — there is no dark variant. (`iPhone Air` is the smoke device; no iPhone 16 sim exists on this machine. Two `iPhone Air` sims exist — use the booted one.)

**Audit checklist — complete ALL before proceeding:**

1. **Element inventory**: List every element on the surface (cards, buttons, language pills, progress bar, lyrics, tab/nav chrome, parent-gate, charts). Nothing is exempt.
2. **PIL sample every surface/card element** on the capture. Record exact RGB of fill, border, and nearest background pixel.
3. **Typography check**: font, weight, size, color token of every text element visible. Tre Voci uses the **Nunito variable font** (`Font+Nunito.swift`, registered in Info.plist `UIAppFonts`) — flag any element falling back to `.system`.
4. **Spacing**: measure padding/gap values between key elements. Tap targets ≥44pt (toddler-grade: prefer ≥60pt for primary play/song controls).
5. **Color token audit**: grep for hardcoded `Color(hex:` / `.system` / raw RGB in the files for this surface — everything should route through `Color+Theme.swift`.
6. **Motion baseline**: is there any animation? Note `withAnimation`, `.animation(...)`, spring params, transitions.
7. **Contrast spot-check**: primary text vs background, language-primary text on language-bg.

Output a **Findings Table** with: Element | Current token/value | Target token/value | Mobbin ref (app + screen) | RICE score. The Target column must trace to a reference or an existing Tre Voci token — never an unsourced "feels better".

**RICE scoring** (required for every finding):
- Reach: 10=all users, 7=most, 5=some, 3=few
- Impact: 10=critical visual sin, 7=notable, 5=minor, 3=polish
- Confidence: 100/80/50/20%
- Effort: 1=one-liner, 2=small, 3=moderate, 5=complex
- Priority: Critical >50, High 20–50, Medium 10–20

---

## Phase 1: Plan

Write a tight spec. Required sections:

### Elements In Scope
Exhaustive list from the audit. Every element you intend to touch.

### Elements Out of Scope (hardcoded)
- **VoiceOver / accessibility semantics** — always out of scope unless explicitly added. (Note: Dynamic Type and tap-target sizing ARE in scope — they're core to a kids app.)
- System-owned chrome (AirPlay route picker, AVRoutePickerView internals, system volume HUD)
- Audio pipeline, AVAudioSession, persistence/UserDefaults logic

### Files Touched
List every Swift file that will change. If it's not listed, it doesn't get touched. Surfaces map to `TreVoci/Views/<area>/`:
- home → `Views/Home/` (HomeView, SongCard, DailyMixCard, CultureSection)
- player → `Views/Player/` (PlayerView, ProgressBar, LanguagePicker, LyricsView)
- onboarding → `Views/Onboarding/` (OnboardingContainer, NameStep, LanguageStep, SpeakerStep)
- parentzone/settings → `Views/ParentZone/` (ParentZoneView, SettingsView, ParentGateView, ExposureChart)
- donation → `Views/Donation/` (net-new: DonationView + StoreKit tip-jar; reached from Parent Zone, parent-gated). Apple StoreKit only — zero third-party deps, no network by us, no tracking. Optional, no-pressure, works offline-after-purchase.
- splash → `Views/SplashView.swift`
- shared chrome → `Views/Shared/`

### Acceptance Criteria
Pixel-level, and where a value came from a reference, cite it (e.g. "card radius 20 — matches Yoto home tile, Mobbin"). Examples:
- "All card fills route through `Color.warm`/`.cream`; zero raw `Color(hex:` introduced"
- "Primary play button tap target ≥60pt; secondary controls ≥44pt"
- "Language-primary text on language-bg contrast ≥4.5:1 (e.g. chineseRed on chineseBg)"
- "Body text contrast ≥4.5:1, large titles ≥3:1 (light-only palette)"
- "Motion: median ≤12ms, max ≤25ms, 0 stutters via analyze.py"

### Worker Contract
Paste into every implementer prompt — non-negotiable:
```
Before returning, you MUST:
1. Build green: xcodebuild -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air' build
2. App launches — confirm the target screen renders. Boot the sim, launch the app, sleep 5,
   take a screenshot, and confirm the surface (not a crash/blank) is visible.
3. Take a screenshot (light — app is light-only) and PIL-sample 3 key elements. Report the RGB values.
4. git status — confirm ONLY the listed files are modified, nothing else staged
Build green alone is NOT pass. App must be in foreground with the target screen visible.
Zero new dependencies (Apple frameworks only). Swift 6, @Observable (never ObservableObject).
```

---

## Phase 2: Implement

### Inline vs subagent decision
- ≤5 files, mechanical token replacements → **implement inline** (Edit tool, no subagent)
- >5 files or novel transitions → spawn a general-purpose implementer subagent

### Subagent dispatch
```
Agent({
  subagent_type: "general-purpose",
  mode: "bypassPermissions",
  prompt: "<spec> + <worker contract above>"
})
```

### Stall timeout: 20 minutes
If a worker hasn't returned within ~20 min, **cancel it, read the tree yourself, commit if the work is done**. Do not wait. The worker's job is to put code in files — the orchestrator's job is to verify and ship.

### SwiftUI discipline (Tre Voci-specific)
- **No new dependencies, ever** — Apple frameworks only. If polish "needs" a library, it doesn't ship.
- **`@Observable`, never `ObservableObject`** — match the existing pattern.
- **Tokens only** — new colors go through `Color+Theme.swift`; never inline a fresh `Color(hex:)` in a view.
- **iPad parity** — wrap wide content in `.readableContentWidth()`; verify the change on iPad if `device: ipad|both`.
- **Toddler-grade tap targets** — primary controls ≥60pt; never shrink a play/song hit area below 44pt for the sake of density.

---

## Phase 3: Gate

Run every acceptance criterion from Phase 1. Do NOT commit until all pass.

### Pixel gate (PIL)
```python
from PIL import Image
img = Image.open("/tmp/pd-gate-light.png")
px = img.load()
# Sample at known coordinates; report (R,G,B). Verify against the token's expected hex.
```

For cards: fill matches `.warm`/`.cream` family. For language surfaces: primary text channel matches the language primary, sits on its language-bg. Confirm no muddy off-token shades crept in.

### Motion gate
```bash
# Record a screen-capture of the interaction, then analyze frame timing.
xcrun simctl io "$UDID" recordVideo /tmp/pd-motion.mp4 &   # ctrl-c / kill after interaction
# Pass: median ≤12ms, max ≤25ms, 0 stutters, 0 pops
```
If you have a frame-timing analyzer wired up, run it; otherwise eyeball at 0.25× and confirm no dropped frames on the transition.

### Contrast gate
Body text ≥4.5:1, large titles/UI ≥3:1 (light-only palette). Language-primary on language-bg ≥4.5:1. Resting glyphs legible on warm/cream surfaces.

### Test gate
```bash
xcodebuild test \
  -scheme TreVoci \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -only-testing:TreVociTests
```
Unexpected failures = bugs. Tre Voci has no snapshot suite by default — if you add one, record baselines deliberately and commit them separately.

---

## Phase 4: Commit

Gate must be fully green. Orchestrator writes the commit message — never the worker.

```
git add <specific files only — never git add -A>
git commit -m "$(cat <<'EOF'
polish([surface]): [what changed]

[One sentence on WHY — e.g. "Unifies three card fills to the warm/cream token pair."]

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Tre Voci Design System Reference

### Color tokens (`TreVoci/Extensions/Color+Theme.swift`)
| Category | Tokens |
|----------|--------|
| Base | cream #FBF8F1 · warm #F5F0E6 · sand #E8E0D0 · bark #3A3028 · stone #8B7E6E · mist #B8ADA0 |
| Language primaries | italianGreen #2A6B45 · chineseRed #C43B3B · englishBlue #2D5BA9 |
| Language backgrounds | italianBg #EDF5F0 · chineseBg #FDF0F0 · englishBg #EDF2FA |
| Accents | coral #FF7B6B · rose #FF6B8A · peach #FFAD8F · gold #FFB84D |

Rule: **bark** is the primary text ink, **stone/mist** are secondary/tertiary, **warm/cream/sand** are surfaces. Language color = the active language's primary on its bg. Never introduce a color outside this palette without adding it to `Color+Theme.swift` first.

### Layout
`readableContentWidth(_ maxWidth: 640)` caps reading-column width and centers on iPad/landscape; no-op on iPhone. Wrap any new wide content in it.

### Typography
**Nunito variable font** (`TreVoci/Extensions/Font+Nunito.swift`, registered in `Info.plist` under `UIAppFonts`; the Fonts folder is a folder-reference in pbxproj). Use the project's Nunito helpers — never raw `.system`. Supports Dynamic Type — verify large content sizes don't clip toddler-facing controls.

### Gotcha — `.bark` won't infer
Use `Color.bark` **explicitly** with `.foregroundStyle(Color.bark)`. The shorthand `.foregroundStyle(.bark)` fails to infer and won't compile. Same for any custom token used in a `ShapeStyle` position.

### Acceptance thresholds (absolute)
- New raw `Color(hex:` in a view: 0 (route through tokens)
- New dependencies: 0 (Apple frameworks only)
- Primary control tap target: ≥60pt; any control: ≥44pt
- Body text contrast: ≥4.5:1
- Large title / UI contrast: ≥3:1
- Motion median: ≤12ms per frame
- Motion max: ≤25ms
- Stutters / pops: 0

---

## Failure-Prevention Rules (burn these in)

| Rule | Why |
|------|-----|
| Audit ALL elements before spec — if you didn't sample it, you'll miss it | Missed chrome elements force multi-pass reworks |
| Worker MUST launch app, not just build | "Build green" can still be a launch crash |
| Cancel stalled worker at 20 min, take over inline | Stalled workers burn an hour for nothing |
| VO out of scope; Dynamic Type + tap targets IN scope | Kids app: sizing is core, VO semantics are backlog |
| Sample coordinates before proposing root cause | Avoid misdiagnosing a token bug as a layout bug |
| Inline for ≤5 files | Subagent overhead only pays off at scale |
| Tokens only — never inline a fresh `Color(hex:)` in a view | Off-token shades fragment the warm palette |
| Zero new dependencies — Apple frameworks only | Hard project constraint; a polish library is not worth it |
| Never `git add -A` | Use specific file paths; never stage .DS_Store or xcuserstate |
| Verify on iPad when device includes ipad | `readableContentWidth` only helps if it's applied |
