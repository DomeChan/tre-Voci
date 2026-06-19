# Value framework — TEMPLATE

> **One-time setup.** Copy this file to `VALUE_FRAMEWORK.md` (same directory) and fill in the
> `«…»` placeholders. The orchestrator reads `VALUE_FRAMEWORK.md`, not this template. Everything
> here is project-agnostic scaffolding plus a reusable lens library — only §1 and §2 need your input.

**Read this BEFORE the FRAME phase.** It answers "is this idea valuable to *our* users?" — independent of which platform, market, or codebase the work happens in.

Three layers:

1. **Principles** — what the product is *for*. Apply across markets and surfaces. You author these.
2. **Personas** — concrete users in concrete contexts. Pick one per invocation. You author these.
3. **Lenses** — questions an ideator asks through. A generic library is provided; extend with domain lenses.

When some existing implementation (a sibling app, a competitor, a known-good site) is the best reference, the framework points to it as **evidence — not authority**. Always evaluate references against your principles, not the other way around. Sometimes the honest answer is "no one's done this well yet — we set the bar."

---

## 1. Principles — what this product is for  «AUTHOR THIS»

> List 6–12 immutable principles. Each is a one-line falsifiable test an ideator can apply.
> These are your brand/product spine — they should rarely change. Replace the examples below.

| # | Principle | One-line test |
|---|-----------|---------------|
| 1 | **«Core mission»** | Does this measurably move «the core outcome», or only engagement? Engagement-for-engagement = KILL. |
| 2 | **«Clarity of value»** | Does this show *concrete value* to the user, or only abstract/vanity metrics? |
| 3 | **Trust through proof** | Does the system show evidence it's working (receipts, audit trails, heartbeats, status)? Magic without proof = mistrust. |
| 4 | **«Relationship/partner alignment, if any»** | Does this honor the user's existing trust anchors instead of bypassing them? |
| 5 | **Just-in-time, not always-on** | Does this surface info *when the user needs it* rather than as constant nagging? Always-on = noise. |
| 6 | **Honest about limitations** | Systems lie, pipelines lag, data drifts. The product *says so*. Trust > false perfection. |
| 7 | **Cultural / locale fit** | Language, RTL, regional copy, local formats. Generic UI in a specific market = friction. |
| 8 | **Cross-surface coherence** | Same voice and brand across every surface. Inconsistency at handoff = abandonment. |
| 9 | **User agency** | Does this give the user a choice/confirmation, or act on them? The user's data, the user's decision. |
| 10 | **Time-to-first-value** | Can a brand-new user feel one concrete benefit in their first session? Long onboarding before payoff = churn. |

When IDEATE produces a candidate, it must declare which principles it serves. KILL rejects candidates that serve none, and flags candidates that *trade* one principle for another for explicit user resolution.

---

## 2. Personas — who we build for  «AUTHOR THIS»

> Define 1–4 concrete personas. Pick one per invocation (or "none" for pure-internal targets).
> The FRAME agent grounds the brief in the persona; IDEATE agents bias toward its jobs-to-be-done.
> Replace the example. Keep at least JTBD + sensitivities + anti-patterns for each.

### Persona «A» — «short label» («name, age, context»)

- **Context / environment**: «device tier, connectivity, setting».
- **Relationship**: «how they relate to the product / any partner / their existing trust anchors».
- **Language / locale**: «languages, RTL needs, formal-copy expectations».
- **Top jobs-to-be-done**:
  1. «"In their words, the thing they're trying to accomplish."»
  2. «…»
  3. «…»
- **Sensitivities**: «privacy, proof, cost, religious/cultural/regulatory copy, "free" claims, …».
- **Anti-patterns**: «what reads as wrong/tone-deaf to this user — these become KILL criteria».

### Persona «B» — «…»

«repeat the block»

### Persona «Generic / pre-market» (recommended to keep one)

- **Context**: undefined — build for "no specific market today, any market tomorrow."
- **Language**: baseline language, designed for translation from day one (no concatenated strings, ICU plurals).
- **Top jobs-to-be-done**:
  1. "Show me, in <60 seconds, why this is worth my time."
  2. "Don't ask for permissions before I've seen value."
  3. "Make the core value legible — how am I doing, and what should I change?"
- **Sensitivities**: high — pre-trust user. Every screen is a referendum on whether they keep using it.
- **Anti-patterns**: feature-richness without journey clarity; copy that assumes brand recognition we don't have.

---

## 3. Lenses — the questions ideators ask

Use 3–6 per invocation, picked to match target + persona. The value and reference lenses below are
generic and reusable as-is. Add domain-specific value lenses and market lenses for your product.

### Value lenses (always at least one)

| Lens | Question |
|------|----------|
| `jobs-to-be-done` | What is the user trying to accomplish in *this exact moment* on this surface? What lets them succeed faster, with less anxiety? |
| `trust-leakage` | Where does trust leak (accuracy, privacy, reputation, broken promises)? Repair the leak, don't paper over it. |
| `legibility` | Can a *cold* user understand this in <5 seconds? Read the screen with no context — do you know what to do next? |
| `proof-of-life` | Does the system show it's working? Audit trails, heartbeats, status counters. |
| `time-to-first-value` | Can a brand-new user feel one concrete benefit in their first session? |
| `«domain value lens»` | «e.g. for a safety product: "Does this move actual outcome X or just the feeling of it?" — AUTHOR per product» |
| `screen-as-ad` *(optional)* | Would a user reflexively screenshot and share this surface? Hero number + brand watermark + shareable caption + frame test. Apply only on surfaces that could carry a genuine flex; never on settings, forms, error/empty states, or low/negative-signal surfaces. |

### Market / persona lenses (use when a persona is set)  «extend per market»

| Lens | Question |
|------|----------|
| `cultural-fit-«market»` | Does this respect the market's language, RTL, regulatory copy, local rails, currency/number formats, device/bandwidth constraints? |
| `cross-market-portability` | If we build this for one market today, what changes for another tomorrow? Is the abstraction reusable or did we hardcode? |
| `regulatory-fit` | Market-specific requirements (data residency, disclosure rules, advertising standards)? |

### Cross-surface lenses (use when scope spans surfaces)

| Lens | Question |
|------|----------|
| `surface-handoff` | What happens at the boundary between surfaces (web↔app, app↔partner portal, app↔car/watch)? One continuous product or several loosely-related ones? |
| `responsive-tier` | Does this work across the surface's breakpoints/size classes? |
| `offline-degradation` | What does this look like offline / on a poor connection? Does it lie, hide, or honestly degrade? |

### Reference lenses (always at least one)

| Lens | Question |
|------|----------|
| `best-in-class-reference` | What does the *best implementation we've seen* (a sibling app, a competitor, a known-good site) do here? What does it get right that we don't? Cite the file/screen/URL explicitly. **Evidence, not authority.** |
| `inverse-best-in-class` | What does the *worst implementation* do? What's the trap to avoid? |

### Engineering lenses (generic, reuse as-is)

`technical-risk`, `performance`, `test-coverage`, `simplicity`, `a11y`, `dark-mode`, `design-system`.

---

## How to use this from the FRAME phase

The FRAME agent's brief MUST declare:

```
Target:             <one-line target>
Persona:            <persona key from §2, or "none">
Surface:            <surface key from SURFACES.md>
Principles served:  <list 1-3 from §1>
Principles at risk: <any this work could trade off — flag for KILL>
Lenses:             <3-6 from §3, including ≥1 value lens and ≥1 reference lens>
Reference:          <file:line or URL of the best-in-class reference, if any>
```

KILL rejects ideas that don't map to declared principles. VALIDATE confirms the merged work serves them.

---

## Adapting to a new market or surface

1. **Add a persona** to §2 with concrete JTBD, sensitivities, anti-patterns.
2. **Add cultural/regulatory lenses** to §3.
3. **Reuse all principles in §1** — those are the spine and shouldn't change.
4. **Reuse most engineering + reference lenses** — they generalize.

The framework is intentionally **add-only**: principles immutable, personas extend, lenses extend. That is what makes it portable across markets and surfaces.
