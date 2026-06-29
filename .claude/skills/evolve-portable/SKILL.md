---
name: evolve-portable
description: Autonomous generational improvement loop for any problem in any repo. Frames the target, fans out parallel ideation agents in worktrees, red-teams and kills weak ideas before code is written, allocates survivors to exploit/explore pools, executes in parallel, validates against your project rules, and persists lessons across generations. Project-agnostic — all repo-specific knowledge lives in two config files you fill in (VALUE_FRAMEWORK.md, SURFACES.md). Inspired by evolver (eranshir/evolver), built on Claude Code primitives (Agent + worktree isolation + memory + /loop).
---

# /evolve-portable — Autonomous Generational Improvement Loop

Run a generational improvement loop on any problem in any repo. Modeled on evolver's evolution shape (discover → ideate → execute → validate → evolve), adapted to Claude Code primitives, with one critical addition evolver lacks: a **red-team quick-kill phase** that murders bad ideas *before* any code gets written.

This is the **portable** version of the loop: the orchestration here is generic, and every project-, market-, platform-, and design-system-specific fact is pushed into two config files that you fill in once per repo. Nothing in this file names a company, product, framework, or file path.

**Before first use, do the one-time setup:**

1. Copy `VALUE_FRAMEWORK.template.md` → `VALUE_FRAMEWORK.md` and fill in your project's principles, personas, and any domain lenses.
2. Copy `SURFACES.template.md` → `SURFACES.md` and fill in your build / install / capture / token-path commands per surface.
3. (Optional) Point the design-audit and root-cause delegates at whatever agents your project has. If you have none, the loop falls back to generic prompts.

If those two files don't exist yet, FRAME stops and tells you to run setup.

Delegates (optional, configured in `SURFACES.md`):
- a **design-audit agent** — design review on UI changes (falls back to a generic audit prompt if none configured)
- a **root-cause agent** — deeper grounding when an idea needs investigation (falls back to inline analysis)

---

## Invocation

```
Read .claude/skills/evolve-portable/SKILL.md
Read .claude/skills/evolve-portable/VALUE_FRAMEWORK.md
Read .claude/skills/evolve-portable/SURFACES.md

Run /evolve-portable on: <target description>
Persona: <one of the personas you defined in VALUE_FRAMEWORK §2, or "none" for pure-internal targets>
Surface: <one of the surface keys you defined in SURFACES.md>
Fitness: <how we know it worked — for code targets, a FROZEN evaluator command that emits a comparable scalar (e.g. `<your-eval-cmd> --json` → {metric}); for UI, the G1/G2/G3 gates. This is the fitness contract's scalar + threshold.>
Lenses: <comma-separated lens names, or "default" — must include ≥1 value lens and ≥1 reference lens (see VALUE_FRAMEWORK §3)>
Reference: <file:line or URL of the best-in-class implementation, if any>
Generations: <N, default 1 — multi-gen requires /loop wrapper>
Budget: <max parallel agents per phase, default 4>
Budget per candidate: <max tokens and/or wall-clock per EXECUTE candidate — the invariant that makes generations commensurable; default none, REQUIRED for code targets>
Merge: <manual | auto-safe-only, default manual>
```

If invoked with no arguments, resume the most recent session from `memory/evolve/` and continue the next generation.

**Three-layer architecture (portable by design):**

- `VALUE_FRAMEWORK.md` — what "valuable" means for *your* users. Principles (§1) are your immutable spine; personas (§2) are pickable; lenses (§3) are the questions ideators ask. **You author this once per project.**
- `SURFACES.md` — per-platform adapter table: build, install, capture, theme-toggle, design-token paths, smoke device, touch-target threshold, delegate agent names. **You author this once per project.**
- `SKILL.md` (this file) — the project-agnostic orchestrator that reads both above and runs FRAME → IDEATE → KILL → ALLOCATE → EXECUTE → VALIDATE → VALIDATION GATES → REPORT.

---

## Phase 0 — Asset & Token Inventory (MANDATORY pre-flight for any design / mockup / UI-eval target)

**Read this before FRAME runs.** This phase exists because the single most expensive failure mode in design work is **invent-first instead of read-existing-first** — recreating a logo, a color, a gauge, or a whole content section that already exists in the repo, then iterating for hours on top of that fabricated foundation.

Fire this phase for any target that involves a screen redesign, mockup, audit-and-fix, or "make X look like Y" request. Skip only for pure-backend / pure-infrastructure targets.

Run as one agent, ≤200 lines output, BEFORE FRAME. If any checklist below comes back empty when it shouldn't, FRAME stops and the user is asked whether to widen the search or proceed knowingly.

### 0.1 Asset inventory — use the real asset, never a hand-drawn substitute

For every visual element the redesign might need (logo, icon, brand mark, partner glyph, platform glyph, badge), search the repo in this order and STOP at the first hit:

1. The project's asset directories (drawables / mipmaps / asset catalogs / `public/` / `assets/` — see SURFACES.md for paths).
2. Vector / lottie / SVG sources.
3. Repo-wide: `find . \( -name "*.svg" -o -name "*.webp" -o -name "*.png" -o -name "*.pdf" \) | grep -i <keyword>`.
4. For third-party platform logos (social, payment rails, partner brands): use **Simple Icons** (https://simpleicons.org) — never invent geometry.
5. Only if all miss: declare the asset gap explicitly in the FRAME brief.

### 0.2 Token inventory — read before picking a hex / sp / dp / rem

For every color, font, shape, or spacing decision the redesign will touch, list the canonical token source path **from SURFACES.md** (colors, typography, shape, spacing rows). No raw hex / sp / dp / px in proposals — every value must round-trip to a named token or a documented exception.

### 0.3 Semantic-color resolution — three questions in order

For any accent / tint / highlight the redesign introduces, walk these three questions BEFORE picking a color source. Pick the first that applies — do not jump to (c) because (a) and (b) feel harder.

(a) **Is this driven by brand / partner brand?** → use the brand-tint token source.
(b) **Is this driven by data semantics?** (status, severity, score band, state) → use the production data-driven token map. Name the map.
(c) **Is it pure surface chrome with no semantic meaning?** → use a neutral surface token.

Misordering this (e.g. picking a brand accent on what is actually a data-state signal) is a classic source of multi-iteration thrash.

### 0.4 Production component density check — count the children before redesigning

For any "redesign screen X" target, FIRST open the production component and list every direct child of its root scroll/stack container top-to-bottom. The redesign must account for every section unless an explicit removal decision is logged in the FRAME brief. Shipping a mockup with an empty body because you never counted the real sections is a guaranteed re-do.

### 0.5 Iteration-cost circuit-breaker

If you are on iteration ≥3 of the same mockup / audit / design eval and still adjusting fundamentals — color SOURCE, content density, asset authenticity, brand — **STOP. Re-run Phase 0** with the user present. The cheapest fix at iteration 3 is to throw away the mockup and start from a complete inventory, not to patch on top of a bad foundation.

---

## Phases

```
┌─ FRAME ──────────────────────────────────────────────────┐
│ 1 agent. Read the target, scan repo for relevant         │
│ surfaces, restate the problem with file:line refs,       │
│ confirm the fitness signal. STOPS for user OK if the     │
│ fitness signal is vague — bad fitness = thrashing loop.  │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ IDEATE ─────────────────────────────────────────────────┐
│ N parallel agents in worktrees, one per lens.            │
│ Each returns 3–5 proposals with file:line refs and       │
│ the assumption each proposal attacks.                    │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ KILL (red-team) ────────────────────────────────────────┐
│ 1 agent, fast, no worktree. Adversarial pass on every    │
│ proposal. Kill if: violates project rules, duplicates    │
│ work, contradicts a principle, attacks an assumption     │
│ already killed in memory, or has no plausible path to    │
│ the fitness signal. Survivors carry forward with notes.  │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ ALLOCATE (deterministic) ───────────────────────────────┐
│ Survivors split into:                                    │
│   • EXPLOIT — clear win, low risk → implement            │
│   • EXPLORE — high upside, uncertain → prototype only    │
│   • PARK — needs more info → memory, future generation   │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ EXECUTE ────────────────────────────────────────────────┐
│ Parallel agents in worktrees, one per EXPLOIT/EXPLORE    │
│ idea. Each implements, runs smoke checks (build/lint/    │
│ relevant tests), returns diff + the frozen evaluator's   │
│ scalar. Capped by budget.                                │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ VALIDATE ───────────────────────────────────────────────┐
│ 1 agent. For each diff: project design-token rules,      │
│ dark-mode coverage, reference parity, file-scope sanity. │
│ For UI changes, delegates to the configured design-audit │
│ agent. Output: per-idea merge recommendation (merge /    │
│ revise / reject) with reasoning.                         │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ VALIDATION GATES (mandatory for UI candidates) ─────────┐
│ Three parallel subagents per candidate. ALL must pass    │
│ before the candidate reaches the user-facing merge gate. │
│                                                          │
│  G1  vision-audit — install candidate on the smoke       │
│      device, capture light + dark, dump view bounds.     │
│      Asserts: touch targets ≥ surface threshold,         │
│      typography maps to type tokens, colors map to       │
│      color tokens (no raw hex), shapes from shape         │
│      tokens, dark-mode parity, *and* cell-height         │
│      equality for any grid/row layout (max Δheight       │
│      between sibling cards ≤ 2 units).                    │
│                                                          │
│  G2  regression-diff — render the *same* screen on the   │
│      pre-gen baseline and the candidate. Image-diff      │
│      outside the declared target bbox. ANY non-zero      │
│      delta outside bbox = FAIL with diff overlay.        │
│                                                          │
│  G3  numerical-truth — for every UI element tagged       │
│      `numeric_*` (or marked `[NUMERIC]` in the idea      │
│      brief), re-derive the value client-side from the    │
│      source-of-truth and compare to the displayed text.  │
│      >5% drift = FAIL.                                    │
│                                                          │
│ Failures route back to EXECUTE with the gate's report    │
│ pinned to the worker's prompt — no silent re-spawn.      │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ REPORT + PERSIST ───────────────────────────────────────┐
│ Write generation summary. Persist to memory/evolve/      │
│ <target-slug>.md: killed assumptions, merged ideas,      │
│ rejected ideas + reason, lessons. Future generations     │
│ read this to avoid relitigating dead ground.             │
└──────────────────────────────────────────────────────────┘
            ↓
┌─ MERGE GATE (user) ──────────────────────────────────────┐
│ Manual mode (default): present diffs, wait for y/n.      │
│ Auto-safe-only: auto-merge doc-only or test-only diffs;  │
│ everything else waits for user.                          │
│ Worktrees with rejected diffs: explicitly cleaned up.    │
└──────────────────────────────────────────────────────────┘
```

For multi-generation, wrap in `/loop`:

```
/loop /evolve-portable on: <target>
```

`/loop` with no interval lets the model self-pace via `ScheduleWakeup` — generations fire only when the prior one is reviewed.

---

## Lens library

The lens library lives in `VALUE_FRAMEWORK.md §3`. It's organized into:

- **Value lenses** — must include ≥ 1 (e.g. `jobs-to-be-done`, `trust-leakage`, `legibility`, `proof-of-life`, `time-to-first-value`, plus any domain-specific value lenses you add)
- **Market/persona lenses** — used when a persona is set (`cultural-fit-<market>`, `cross-market-portability`, `regulatory-fit`)
- **Cross-surface lenses** — used when scope spans surfaces (`surface-handoff`, `responsive-tier`, `offline-degradation`)
- **Reference lenses** — must include ≥ 1 (`best-in-class-reference`, `inverse-best-in-class`)
- **Engineering lenses** — `technical-risk`, `performance`, `test-coverage`, `simplicity`, `a11y`, `dark-mode`, `design-system`

> **Reference lenses, not parity lenses.** Do not encode "match platform X" as authority. Another implementation (a sibling app, a competitor, a known-good site) is *evidence* under `best-in-class-reference` — always evaluate it against your own principles in VALUE_FRAMEWORK §1, never the other way around. Sometimes the right answer is "no one has done this well yet — we set the bar."

Suggested combinations:
- **Product/UX target**: `jobs-to-be-done` + `trust-leakage` + `legibility` + `best-in-class-reference` (4 agents)
- **Market expansion**: `cultural-fit-{market}` + `regulatory-fit` + `cross-market-portability` + `best-in-class-reference` (4 agents)
- **Cross-surface**: `surface-handoff` + `legibility` + `responsive-tier` + `best-in-class-reference` (4 agents)
- **Technical hardening**: `technical-risk` + `performance` + `test-coverage` + `simplicity` (4 agents)
- **Design polish**: `design-system` + `dark-mode` + `a11y` + `best-in-class-reference` (4 agents)

---

## Session Directory Structure

```
.claude/evolve/sessions/
  <target-slug>/
    gen-1/
      frame.md              # problem brief + fitness signal
      ideas/
        <lens>.md           # proposals from each lens agent
      kills.md              # red-team kill list with reasons
      allocation.md         # exploit / explore / park
      diffs/
        <idea-slug>.diff
        <idea-slug>.score.md
      validation.md         # per-idea merge recommendation
      report.md             # generation summary
    gen-2/
      ...
```

Persistent lessons (cross-generation, cross-session) go to `memory/evolve/<target-slug>.md` via the auto-memory system.

---

## Agent Prompt Templates

### FRAME agent

> You are framing a target for an evolution loop. Target: **{target}**. Persona: **{persona}**. Surface: **{surface}**. Fitness: **{fitness}**.
>
> **First read** `.claude/skills/evolve-portable/VALUE_FRAMEWORK.md` and `.claude/skills/evolve-portable/SURFACES.md`. If either does not exist, STOP and tell the user to run the one-time setup (copy the `.template.md` files and fill them in). Then read the project's root instructions file (CLAUDE.md / AGENTS.md / README) and scan the repo for surfaces relevant to this target (code, screens, recent commits, related memory entries).
>
> Output a problem brief covering:
> 1. **Persona snapshot** — paste the persona's JTBD + sensitivities + anti-patterns from VALUE_FRAMEWORK §2. One sentence each, in this brief's voice. (Skip if Persona is "none".)
> 2. **Surface adapter** — paste the relevant row from SURFACES.md so EXECUTE workers don't have to look it up: build cmd, install cmd, capture cmd, bounds-dump cmd, theme-toggle cmd, design-token paths, touch-target threshold, delegate agent names.
> 3. **Surfaces in scope** — file:line, screen names, entry path. Cite the specific files an EXECUTE worker would touch.
> 4. **Recent context** — relevant commits, in-progress branches, related memory/evolve entries.
> 5. **Existing constraints** — project-rule-file rules, regulatory facts, platform conventions for the surface.
> 6. **Principles served** — list 1–3 from VALUE_FRAMEWORK §1 that this target actually moves. If you can't list any, the target is mis-scoped — say so and stop.
> 7. **Principles at risk** — any that this work could trade off. Flag explicitly so KILL can use them.
> 8. **Best-in-class reference** — the best implementation of this kind of thing you've seen, anywhere. Cite file:line or URL. It is *evidence, not authority* — if you cite it, also say what would make it wrong here.
> 8a. **Phase 0 inventory output** (for design / mockup / UI-eval targets — MANDATORY):
>     - **Assets found** — file paths to logos, icons, glyphs the redesign will use. If empty, STOP — search wider before continuing.
>     - **Tokens to consume** — color / typography / shape / spacing tokens with their source path (from SURFACES.md). No raw hex / sp / dp / px allowed in proposals.
>     - **Accent SOURCE decision** — for every accent the redesign introduces, declare brand / data-semantic / surface-chrome (Phase 0.3). If `data-semantic`, name the source map.
>     - **Sections in production component** — top-to-bottom list of every direct child of the root container (Phase 0.4). The redesign must address each or log an explicit drop reason.
> 9. **Fitness signal restated** — concrete, falsifiable. Tie at least one criterion to a Validation Gate (G1/G2/G3). Flag if vague.
> 10. **Out of scope** — surfaces, screens, principles this gen explicitly will NOT touch.
>
> Under 600 words. No proposals yet — framing only. STOP and ask the user if persona is unset (and the target isn't pure-internal), surface is unset, or principles served is empty.

### IDEATE agent (one per lens, parallel worktrees)

> You are an ideator using the **{lens}** lens. Target: **{target}**. Persona: **{persona}**. Surface: **{surface}**. Fitness: **{fitness}**.
>
> Read the FRAME brief at `frame.md`. Read `.claude/skills/evolve-portable/VALUE_FRAMEWORK.md` for the lens definition and the persona snapshot. Read existing code in the surfaces FRAME listed.
>
> Propose 3–5 changes through the {lens} lens. For each:
> - **Title** — short, action-oriented
> - **Persona job served** — which JTBD from FRAME's persona snapshot does this attack? Quote it. (Skip if no persona.)
> - **Principle(s) served** — from VALUE_FRAMEWORK §1, by number. Reject your own idea if you can't list one.
> - **Assumption attacked** — the belief that, if wrong, makes this idea worthless
> - **Change** — file:line refs + 1-paragraph description
> - **Numeric leaves** — if this idea displays any computed numeric value (count, average, total, delta, currency), you MUST declare a stable test-id (`numeric_<key>`) for each leaf and the source-of-truth formula (e.g. `avg = sum / count`). Untagged numeric work will be KILLed — G3 cannot validate what it can't find.
> - **Fitness path** — how this moves the fitness signal, including which Validation Gate (G1/G2/G3) will confirm it.
> - **Effort** — S/M/L
> - **Portability note** — if a persona/market is set, one sentence on what would change for another market. If unsure, say so — that's a parking signal.
>
> Do not implement. Do not write code. Output ideas only, ranked by *fragility of the assumption × impact × principle weight*. Worktree should be empty when you finish — no commits.

### KILL agent (red-team)

> You are red-teaming proposals before any code gets written. Read all `ideas/*.md`, the FRAME brief, `VALUE_FRAMEWORK.md`, and the contents of `memory/evolve/<target-slug>.md` (killed assumptions from prior generations).
>
> For each proposal, attempt to kill it. Kill if any apply:
> - Violates a project rule (the root instructions file)
> - Duplicates existing work or an in-progress branch
> - Contradicts a *principle* in VALUE_FRAMEWORK §1 (principles supersede references)
> - Conflicts with the persona's anti-patterns (VALUE_FRAMEWORK §2)
> - Attacks an assumption already killed in memory
> - Has no plausible path to the fitness signal
> - Has no `Principle(s) served` declared, or the declared principle is a stretch
> - **Touches numeric UI without declaring a `numeric_<key>` test-id and a source-of-truth formula** (G3 cannot validate, so it cannot ship)
> - **Invents an asset, hex, or geometry that Phase 0 inventory already covers** (e.g. a custom mark when one exists; a raw `#XXXXXX` when a token already maps it)
> - **Picks an accent SOURCE that contradicts Phase 0.3** (e.g. brand accent on a screen whose accent is data-semantic)
> - **Redesigns a screen without addressing every section listed in Phase 0.4** (silently drops production content)
> - Trades off a principle without explicitly flagging the trade for user resolution
> - Two proposals collide; keep the stronger
>
> Output `kills.md`: for each idea, KEEP or KILL with one-sentence reason citing a principle, persona anti-pattern, or memory entry. Be ruthless — surviving the kill phase is the bar. Aim to cut 40–60%.

### EXECUTE agent (one per surviving idea, parallel worktrees)

> Implement this single idea: **{idea}**. Worktree is isolated; main is untouched.
>
> **STEP 0 — verify worktree base before any code work.** The gen-tip commit is `{gen_tip_sha}`. Run `git log -1 {gen_tip_sha}..HEAD` — if non-empty, you're on the right base. If empty (or target files don't exist in your worktree), the worktree was bootstrapped from a stale commit. Recover with `git reset --hard {gen_tip_sha}` and re-verify before proceeding. **Do not skip this — stale-base recovery silently burns worker tokens.**
>
> Constraints: follow the project rule file exactly — design tokens, dark-mode policy, no hardcoded values, reference parity. Keep changes minimal — no drive-by refactors.
>
> After implementing:
> 1. Run the surface's **build** command (from SURFACES.md).
> 2. Run any tests directly relevant to changed files.
> 3. Run the **frozen evaluator** from the fitness contract (the `Fitness:` command) and write `diffs/<slug>.score.md` with: build pass/fail, tests pass/fail, and **the evaluator's emitted scalar** (the hard number candidates are ranked by) + whether it meets the threshold. Do NOT self-assess a 1–5 — the scalar is the score; a candidate that didn't run the evaluator has no score and cannot win. Caveats go in a separate note, not the score.
> 4. Stay within **Budget per candidate** (tokens/wall-clock). If you hit it before the evaluator is green, stop and record the partial scalar — do not run unbounded (fixed budget makes candidates commensurable).
> 5. Commit on the worktree branch. Do not merge. Do NOT modify the evaluator itself or `.claude/skills/evolve-portable/**` — VALIDATE rejects a candidate that edits the machinery that grades it (frozen-evaluator lock).

### VALIDATE agent

> Validate each EXECUTE diff. For each:
> - Project design-system compliance (shapes, colors, typography, spacing) per SURFACES.md token paths
> - Dark-mode coverage
> - Reference parity (if a reference was declared)
> - File-scope sanity (did it stay in lane?)
> - **Safe-area / window-insets sanity for any new top-of-screen content** — new sheets / modals / headers must consume the platform's safe-area insets so content doesn't clip under the status bar / notch. Pre-existing screens with this bug are fair game to fix as a polish commit when discovered.
> - For UI changes, invoke the configured **design-audit agent** (SURFACES.md). If none is configured, run a generic audit that pins the surface's token paths.
>
> Output `validation.md` with per-idea recommendation: **MERGE** / **REVISE** (with specific asks) / **REJECT** (with reason).

### G1 — vision-audit agent (one per UI candidate, parallel)

> You are validating a single candidate against the project's design system. Worker branch tip: **{candidate_sha}**. Target screen: **{screen_route}** (entry: **{entry_action}**). Use the surface's build / install / capture / bounds-dump / theme-toggle commands from SURFACES.md.
>
> 1. Build the candidate from `{candidate_sha}` worktree.
> 2. Install on the surface's smoke device.
> 3. Drive to `{screen_route}` via `{entry_action}`.
> 4. Capture **light** and **dark** (use the surface theme-toggle; if the app pins a theme, note which theme is dormant).
> 5. Dump view bounds for each capture.
>
> Assertions (FAIL the candidate on any violation):
> - **Touch targets** ≥ the surface's threshold on every interactive node within the target component bbox.
> - **Typography** — every text node's effective font-size maps to a named type token. Raw sizes = FAIL.
> - **Colors** — sample text & background pixels at the center of each card; values must match a named color token or a documented exception. Hex not in the palette = FAIL.
> - **Shapes** — corner radii at card boundaries must round-trip to a named shape token (within 1 unit).
> - **Dark-mode parity** — the dark capture must show *every* element visible in the light capture (no missing tokens, no white-on-white, no contrast < 4.5:1 for body text).
> - **Cell-height equality** — for any layout with sibling cards/rows of matching role, the bounding-box `(bottom - top)` must agree within ≤ 2 units. Floor-only height constraints FAIL when actual rendered heights differ.
>
> Output `validation/g1-vision-{slug}.md`: per-assertion PASS/FAIL with the offending node path or pixel sample. Attach light + dark PNGs and the bbox-overlay PNG to `validation/captures/`.

### G2 — regression-diff agent (one per UI candidate, parallel)

> Detect unintended visual changes outside the candidate's declared scope.
>
> Inputs: candidate worktree (`{candidate_sha}`), pre-gen baseline SHA (`{base_sha}`), declared target bbox (`{bbox_json}` — the rectangle in screen-space the idea is allowed to mutate).
>
> 1. From a *separate* worktree at `{base_sha}`, build + install + capture the same screen (light + dark) using the identical entry path and bounds anchors as G1.
> 2. From the candidate worktree, capture the same screen (light + dark).
> 3. For each pair, image-diff (e.g. ImageMagick `compare -metric AE -fuzz 2%`) over the region *outside* the declared target bbox.
> 4. Any non-zero pixel delta outside the bbox = FAIL. Attach a delta overlay highlighting the unauthorized region.
>
> Edge cases:
> - Status-bar clock / battery: ignore via a top-strip mask.
> - Non-deterministic content (live map, video, animated charts): skip with `SKIP_REASON: non-deterministic`.
> - Animation in flight: take the second of three sequential captures 200ms apart; if hashes still differ across the three, mark `FLAKY` and capture again at idle.
>
> Output `validation/g2-regression-{slug}.md`: PASS/FAIL/SKIP with attached overlays.

### G3 — numerical-truth agent (one per UI candidate that displays computed values)

> Re-derive every numeric UI value from source-of-truth and compare to what is rendered. The candidate MUST tag numeric leaf nodes with a stable `numeric_<key>` test-id so this gate can find them; if not, the gate FAILs with `MISSING_TAGS`.
>
> 1. Build + install candidate, drive to target screen, dump the view tree.
> 2. For each `numeric_*` node, read its rendered text.
> 3. Pull the source data for the same window via the source-of-truth repository/store/API (read SURFACES.md / the code for how this surface exposes data — debug intent, local store snapshot, API call, whichever is cheaper).
> 4. Compute the truth value client-side using the formula declared in the idea brief.
> 5. Compare. >5% drift, or sign mismatch on deltas, or any displayed value outside the truth value's plausible range = FAIL.
>
> Special handling:
> - Durations/formatted values: format the truth value with the *same* helper the UI uses (read it from the diff), then string-compare with a small tolerance.
> - Counts: exact match.
> - Deltas (vs prev period): re-derive both periods; sign and magnitude must match.
>
> Output `validation/g3-numeric-{slug}.md`: per-value table with `displayed | truth | delta | verdict`. Attach the raw source response as JSON.

### Visual audit on real device (post-integration, before final merge)

> Cherry-pick or merge the surviving worker commits onto the gen branch in the integration order recommended by `validation.md`.
>
> **MANDATORY first step before any device install:** clean rebuild to evict stale build-cache from worker worktrees (parallel worker builds pollute shared caches and can produce a candidate that crashes at startup despite correct source). Use the surface's clean-rebuild command from SURFACES.md.
>
> Install on a **real device** when the surface's emulator/simulator can't faithfully render the candidate (large bundles, hardware features). For each gen-N-affected screen:
> - Capture light + dark
> - Run the configured design-audit agent on the captures
> - Verify safe-area / inset behavior on the actual device cutout

---

## Cost & Safety Discipline

- **Default budget**: 4 parallel ideators + 4 parallel executors max. Soft cap, declared at invocation.
- **Per-candidate budget (commensurability)**: when `Budget per candidate` is set, each EXECUTE worker has a hard token/wall-clock ceiling so generations are comparable on fixed cost. The winner is the candidate with the best **frozen-evaluator scalar** under that budget — never a self-assessed number.
- **Frozen-evaluator lock**: a candidate must NOT modify the evaluator that grades it, nor `.claude/skills/evolve-portable/**`. VALIDATE rejects any diff touching those paths. Closes the "worker games its own scorer" hole.
- **Worktree hygiene**: `Agent` calls use `isolation: "worktree"`. Worktrees with no changes auto-clean. Rejected diffs: explicitly clean up the worktree at end of generation. **At end of REPORT, run `git worktree list` and remove any locked worktrees from this generation** — they consume disk + build metadata.
- **Build-cache hygiene**: worker builds populate *shared* caches with intermediate outputs from in-progress states. After cherry-picking worker commits, the first incremental build is **untrusted**. VALIDATE MUST run the surface's clean-rebuild command before any device install.
- **Branch isolation**: Never run on `main` or a release branch. Skill checks current branch and refuses if on `main`/`release/*`.
- **Manual merge default**: Auto-merge is opt-in per invocation, and even then only for `auto-safe-only` (doc-only or test-only diffs).
- **Memory of killed assumptions**: Each generation reads `memory/evolve/<target-slug>.md` first so we don't relitigate dead ideas.
- **Loop sanity**: Multi-gen loops require `/loop`, which keeps the user in the loop. No silent runaway.

---

## Operational hygiene — mechanical, mandatory, easy to forget

Treat these as part of the skill's contract.

1. **Bundle ideas that touch the same file.** If KILL leaves multiple survivors in adjacent regions of one file, bundle them into one EXECUTE worker rather than spawning N parallel workers that produce mergeable-but-overlapping diffs.
2. **Tell EXECUTE workers about each other.** Each worker's prompt should include a one-line summary of what other slots are touching, plus the explicit kill notes for sibling ideas in their own lens, so they don't over-scope.
3. **EXECUTE worker first action is always: verify gen-tip base.** Pass the gen-tip SHA in the prompt. If `git log -1 <gen_tip>..HEAD` is empty, `git reset --hard <gen_tip>` and re-verify. The single most common worker failure mode.
4. **VALIDATE = clean rebuild + real device when needed.** Never trust an incremental build after worker integration. Never trust an underpowered emulator for visual audit of a heavy candidate.
5. **Insets are part of design audit.** Every UI-touching slot's VALIDATE includes a safe-area / inset check. Pre-existing inset bugs surfaced during a gen are fair game to fix.
6. **History noise from bisection is acceptable on the gen branch, not on the merge target.** Use `git cherry-pick` of the meaningful commits when merging upstream, not a noisy `git merge` of the bisection-cluttered evolve branch.
7. **Persist parked-idea triggers in memory.** `memory/evolve/<target-slug>.md` must list each PARKed idea with its **re-evaluation trigger** so gen-N+1 knows when to revisit.
8. **The validation gates are not optional.** UI candidates that skip G1/G2/G3 cannot reach the merge gate. Failures route back to EXECUTE with the gate's report pinned. A worker bounced twice on the same gate is automatically PARKed and its assumption added to `kills.md` for the next generation.
9. **Tag numeric leaves at IDEATE time.** Any idea that touches a numeric UI value must name its `numeric_<key>` test-id in the proposal. KILL rejects untagged numeric work — G3 cannot assert a value with no tag, and a wrong number with no tag will ship silently.
10. **Read-existing-first for design / mockup / UI-eval targets.** Phase 0 (Asset & Token Inventory) is mandatory before FRAME for any target that touches a screen. A 10-minute repo grep at iteration 1 prevents burning 5 iterations on inventable problems. If you're on iteration ≥3 still arguing fundamentals — STOP, re-run Phase 0 with the user.

---

## When NOT to use /evolve-portable

- **No clear fitness signal.** If you can't say what success looks like in one sentence, don't run this. Scope the target down first.
- **Cross-cutting refactors.** Worktree isolation breaks down when ideas overlap heavily. Run sequentially instead.
- **Production hotfixes.** Use direct implementation. Evolution is for *exploration*, not urgency.
- **Targets that need real user data.** Evolver-style loops can't replace A/B testing. Use this to generate hypotheses, not validate them.

---

## Example Invocations

These reference *placeholder* personas/surfaces — substitute the ones you defined in your own `VALUE_FRAMEWORK.md` / `SURFACES.md`.

```
# Product/UX target, mobile surface
Run /evolve-portable on: <feature> adoption on the <screen> tab
Persona: <your-persona-key>
Surface: <your-mobile-surface-key>
Fitness: G1 design audit ≥ 8/10 + G3 numerical-truth PASS on <stat> + user completes <action> in <2 taps
Lenses: jobs-to-be-done, trust-leakage, legibility, best-in-class-reference
Reference: <path-or-url to best-in-class>
Generations: 1
Merge: manual
```

```
# Technical hardening, no persona/surface user — internal pipeline
Run /evolve-portable on: <subsystem> crash resilience
Persona: none
Surface: <your-surface-key>
Fitness: <your-test-cmd> passes; G2 regression-diff PASS on <screen>; double-start scenarios covered by tests
Lenses: technical-risk, test-coverage, simplicity, performance
Generations: 3
Budget: 3
Merge: auto-safe-only
```

```
# Web only — value-prop above-the-fold
Run /evolve-portable on: landing page hero — value prop in <5s
Persona: <your-web-visitor-persona>
Surface: web
Fitness: G2 regression-diff PASS (no layout shift); lighthouse perf ≥ 90; design audit ≥ 8/10; copy comprehensible to a cold reader
Lenses: legibility, time-to-first-value, best-in-class-reference, responsive-tier
Reference: <two best-in-class sites>
Generations: 1
Merge: manual
```
