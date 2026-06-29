# Surface adapters — TEMPLATE

> **One-time setup.** Copy this file to `SURFACES.md` (same directory) and fill in the `«…»`
> placeholders for the surfaces your project ships. The orchestrator reads `SURFACES.md`, not this
> template. The principles in `VALUE_FRAMEWORK.md` and the orchestration in `SKILL.md` are
> surface-agnostic — everything platform-specific lives here. To run on a new surface, add a column.

---

## Adapter table  «AUTHOR THIS»

> One column per surface key you'll pass as `Surface:` at invocation. Delete columns you don't ship,
> add ones you do. The placeholder commands below are *illustrative shapes*, not prescriptions —
> replace with your real toolchain (Gradle/Xcode/npm/cargo/make/…).

| Capability | `«mobile-a»` | `«mobile-b»` | `«web»` |
|---|---|---|---|
| **Repo root** | `«/path/to/repo-a»` | `«/path/to/repo-b»` | `«/path/to/web-repo»` |
| **Build (debug)** | `«debug build cmd»` | `«debug build cmd»` | `«npm run build»` |
| **Build (release)** | `«release build cmd»` | `«release build cmd»` | `«npm run build && npm run start»` |
| **Clean rebuild** | `«clean + no-cache build cmd»` | `«…»` | `«rm -rf .next && npm run build»` |
| **Install / serve** | `«install cmd»` | `«install cmd»` | `«npm run dev → localhost:3000»` |
| **Launch** | `«launch cmd»` | `«launch cmd»` | `«open http://localhost:3000»` |
| **Capture (PNG)** | `«screenshot cmd»` | `«screenshot cmd»` | `«playwright screenshot …»` |
| **Bounds dump** | `«view-hierarchy dump cmd»` | `«…»` | `«page.locator(...).boundingBox()»` |
| **Theme toggle** | `«dark/light toggle cmd»` | `«…»` | `«--color-scheme flag / prefers-color-scheme»` |
| **Smoke device** | `«real device / emulator id»` | `«…»` | `«Chromium 1280×800 + 390×844 + 768×1024»` |
| **Design tokens — colors** | `«color token source path + symbol»` | `«…»` | `«CSS vars --color-* / theme.colors.*»` |
| **Design tokens — typography** | `«type token source path + symbol»` | `«…»` | `«CSS vars --font-*»` |
| **Design tokens — shape** | `«shape/radius token source»` | `«…»` | `«--radius-* CSS vars»` |
| **Test runner** | `«unit test cmd»` | `«…»` | `«npm test»` |
| **Lint** | `«lint cmd»` | `«…»` | `«npm run lint»` |
| **A11y check (auto)** | `«a11y harness»` | `«…»` | `«axe-core via Playwright»` |
| **Touch-target threshold** | `«48dp»` | `«44pt»` | `«24×24px (WCAG 2.2 SC 2.5.8); 44×44 on coarse pointer»` |
| **Design-audit agent** | `«agent name or "generic"»` | `«…»` | `«…»` |
| **Root-cause agent** | `«agent name or "inline"»` | `«…»` | `«…»` |
| **Non-deterministic content** | skip G2 with `SKIP_REASON: non-deterministic` | same | same |

---

## How surface choice flows through the skill

1. **Invocation declares surface** (one of your column keys).
2. **FRAME** reads the matching column to populate file paths, build commands, capture commands, and the delegate agent names.
3. **EXECUTE** runs the surface's build + test + lint commands. The worker prompt includes the column inline so the worker doesn't have to look it up.
4. **VALIDATION GATES** — G1/G2/G3 use the surface's capture + bounds-dump + theme-toggle commands. Same assertions, different transport.
5. **VALIDATE design audit** — invokes the column's design-audit agent. If it's `generic`, fall back to a generic prompt that pins the surface's token paths from the table.

---

## Surface-specific gotchas  «AUTHOR per surface»

> Record the traps that bit you once so they never bite twice. Examples of the *kind* of thing to note:

### `«mobile-a»`
- «Worker worktrees pollute the shared build cache → the first post-integration build is untrusted; always clean-rebuild before device install.»
- «Release applies shrinking/obfuscation that debug skips → never validate a release-bound candidate using only the debug build.»
- «Underpowered emulator can't render large bundles → use a real device for visual audit.»

### `«mobile-b»`
- «Simulator can't exercise certain hardware (sensors, in-car, NFC) → use a real device for those.»
- «Toggle the relevant accessibility flags (reduce-motion, differentiate-without-color) in G1 if the candidate touches motion/color.»

### `«web»`
- «SSR: capture both initial HTML render and post-hydration to catch layout shift.»
- «Test `prefers-reduced-motion: reduce` for animation-heavy candidates.»
- «`lang`/`dir` drive RTL: capture both locales when the persona is bilingual.»
- «Add a Lighthouse budget as an extra G1 gate: FAIL if perf/a11y/SEO drops >5 points vs base.»

### Cross-surface (≥ 2 surfaces)
- Each surface gets its own EXECUTE worker; they share the IDEATE artifacts and the FRAME brief.
- VALIDATION runs once per surface. A cross-surface candidate cannot merge until ALL surfaces pass their gates.
- A `surface-handoff` lens MUST be in the lens list — confirms the boundary feels continuous.

---

## Adding a new surface

1. Add a column to the adapter table: build / clean-rebuild / install / capture / bounds / theme-toggle / tokens / runner / lint / a11y / touch-target / delegate agents.
2. Note any surface-specific gotchas above.
3. Add a `design-audit-«surface»` agent (or set the column to `generic` for the fallback prompt).

Principles in `VALUE_FRAMEWORK.md` do not change. Personas may pick up a new entry if the new surface implies a new user; existing personas shouldn't be edited — only extended.
