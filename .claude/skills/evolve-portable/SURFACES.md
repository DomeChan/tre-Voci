# Surface adapters — Tre Voci

> Adapted for **Tre Voci**. One shipping surface today: `ios` (SwiftUI, iOS 17+, portrait-only,
> zero third-party deps). A `flutter` column is stubbed for the planned cross-platform migration
> (see `docs/` / the Flutter migration commit) — leave it `n/a` until that work starts.
> The orchestrator reads THIS file.

---

## Adapter table

| Capability | `ios` (current) | `flutter` (planned, not yet built) |
|---|---|---|
| **Repo root** | `/Users/domenico/Documents/tre-Voci` | same repo, future `flutter/` subdir |
| **Build (debug)** | `xcodebuild -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air' build` | `n/a` (`flutter build ios --debug` later) |
| **Build (release)** | `xcodebuild -scheme TreVoci -configuration Release -destination 'platform=iOS Simulator,name=iPhone Air' build` | `n/a` |
| **Clean rebuild** | `xcodebuild clean -scheme TreVoci` then build; or `rm -rf ~/Library/Developer/Xcode/DerivedData/TreVoci-*` | `n/a` |
| **Install / serve** | MCP: `mcp__xcodebuildmcp__build_run_sim` (boots sim, installs, launches; defaults set via `session_set_defaults` → project `TreVoci.xcodeproj`, scheme `TreVoci`, sim `iPhone Air`, bundleId `com.trevoci.app`) | `n/a` |
| **Launch** | `mcp__xcodebuildmcp__launch_app_sim` (or `build_run_sim`) | `n/a` |
| **Capture (PNG)** | `mcp__xcodebuildmcp__screenshot` (`returnFormat: path`) | `n/a` |
| **Bounds dump** | `mcp__xcodebuildmcp__snapshot_ui` (rs/1 semantic snapshot with `elementRef` targets + text) | `n/a` |
| **Theme toggle** | **Light-only by design** — no dark variant. (If ever needed: `xcrun simctl ui booted appearance dark`, but the app uses a fixed custom palette, so verify against `Color+Theme`, not system colors.) | `n/a` |
| **Smoke device** | `iPhone Air` simulator (**no iPhone 16 sim available** on this machine). UDID is per-session; get via `mcp__xcodebuildmcp__list_sims`. | `n/a` |
| **Design tokens — colors** | `TreVoci/Extensions/Color+Theme.swift` — `Color.{cream,warm,sand,bark,stone,mist,coral,rose,peach,gold}` + per-language `{italianGreen,chineseRed,englishBlue}` and `{italianBg,chineseBg,englishBg}`. ⚠️ use `Color.bark` **explicitly** with `.foregroundStyle(...)` — `.foregroundStyle(.bark)` fails to infer. |
| **Design tokens — typography** | `TreVoci/Extensions/Font+Nunito.swift` — Nunito **variable** font (from Google Fonts GitHub; static URLs 404). Registered in `TreVoci/Info.plist` under `UIAppFonts`. Fonts folder is a **folder reference** in pbxproj. |
| **Design tokens — shape/spacing** | No central token file — radii/spacing are **inline literals** in views. Match the surrounding view's existing values; if introducing a scale, propose it as a new token file (and log the exception in FRAME). |
| **Test runner** | ⚠️ **No test target exists** (only the `TreVoci` app target/scheme). `xcodebuild test` → "scheme not configured for the test action." Use `python3` catalog-integrity checks (see gotchas) + runtime smoke as the regression substitute until a test target is added. |
| **Lint** | None configured (no SwiftLint). For `CLAUDE.md` size, the `claude-md-lint` skill exists. |
| **A11y check (auto)** | No automated harness. `snapshot_ui` surfaces accessibility labels/text; otherwise manual (Accessibility Inspector). Assert every interactive node has a label + ≥44pt. |
| **Touch-target threshold** | **44×44 pt** (per `CLAUDE.md`). |
| **Design-audit agent** | `HIGAgentSkills` skill (Apple HIG reference, OS 27) for spec/measurement review; `ios-simulator-testing` / `verify` skills for runtime. Else `generic`. |
| **Root-cause agent** | `Explore` agent for read-only code-spelunking; else inline. |
| **Non-deterministic content** | Player mid-playback (audio position, breathing emoji, caption fades) is time-based → **G2 visual regression: `SKIP_REASON: non-deterministic`**. Capture at fixed states only (paused at t=0, specific seeked positions, non-player screens). |

---

## How surface choice flows through the skill
1. Invocation declares `Surface: ios`.
2. FRAME pastes the `ios` column (build/capture/token paths/delegates) into the brief.
3. EXECUTE runs the build; **no test/lint** — substitute the catalog-integrity Python checks below.
4. VALIDATION GATES (G1 vision / G3 numeric-truth) use `screenshot` + `snapshot_ui`; **G2 skipped for player mid-playback** (non-deterministic).
5. Design audit → `HIGAgentSkills`/generic, pinning the token paths above.

---

## Surface-specific gotchas — `ios`

- **SourceKit false positives**: the editor shows "Cannot find type 'X'" for cross-file refs that build fine, and macOS-unavailable warnings (it compiles for macOS context). **Trust `xcodebuild` output, not editor diagnostics.**
- **pbxproj is hand-managed**: adding a Swift file requires entries in BOTH the Sources build phase and FileReference sections; ID prefixes AA/AB/AC/AD/AE/AF. A worktree EXECUTE worker that adds files must edit the pbxproj or the build won't see them.
- **Audio & Fonts are folder references** (not groups): they bundle preserving subdirectory structure. **Do not drop stray files into `TreVoci/Resources/Audio/`** — everything there ships in the app (a stray `SongCatalog.json` once got bundled). The real catalog is `TreVoci/Resources/SongCatalog.json` (bundle root); the app loads it via `Bundle.main.url(forResource:"SongCatalog", withExtension:"json")`.
- **iOS 17 floor**: use `Calendar.current.ordinality(of:.day,in:.year,for:)`, **not** `.component(.dayOfYear)` (iOS 18+). Don't introduce iOS-18-only APIs.
- **Swift 6 / `@Observable`**: classes are `@Observable @MainActor`; `@State`/`@Bindable`/`@Environment`, **never** `ObservableObject`/Combine. Watch for "main actor-isolated property … from a Sendable closure" warnings (pre-existing in `ParentGateView`).
- **Zero dependencies**: Apple frameworks only. Any SPM/CocoaPods addition violates Principle (zero-dependency) → KILL.
- **`appintentsmetadataprocessor` warning** in builds is harmless system noise.
- **UI automation may be disabled**: in some MCP configs only `screenshot`/`snapshot_ui` (read-only) are available — `tap`/`type` are not, so you **cannot always drive onboarding→player**. To reach a player for G1, you may need to pre-seed `UserDefaults` (keys `tre_voci_app_state` / `tre_voci_onboarding_complete`) via `simctl`, and note that audio can't be *heard* in CI — verify sync via data/logic, not by ear.
- **Worktree isolation works well here**: XcodeBuildMCP gives each worktree its own DerivedData (`~/Library/Developer/XcodeBuildMCP/workspaces/...`), so parallel EXECUTE builds don't collide.

### Catalog-integrity check (the de-facto "test runner" — use in EXECUTE/VALIDATE)
```python
# every audio file referenced exists; lyric times monotonic & within file duration
import json, os, subprocess
d=json.load(open('TreVoci/Resources/SongCatalog.json')); A='TreVoci/Resources/Audio'
def dur(p): return float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',p]).strip())
for s in d['songs']:
  for lang,rel in s['audioFiles'].items():
    p=os.path.join(A,rel); ts=[l['time'] for l in s['lyrics'].get(lang,[])]
    assert os.path.exists(p) and ts==sorted(ts) and (not ts or ts[-1]<=dur(p)+0.5), (s['id'],lang)
```

---

## Adding a surface (when Flutter migration starts)
Fill the `flutter` column (build/clean/install/capture/bounds/theme/tokens/runner/lint/a11y/touch-target/delegates),
add its gotchas, and add a `surface-handoff` lens to any cross-surface run. Principles in `VALUE_FRAMEWORK.md` don't change.
