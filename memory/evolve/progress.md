# Evolve Progress — Target: Progress / Exposure chart

Tracks generational evolution of the Parent Zone exposure/progress chart.

## Generation 1

**Target:** Make the exposure chart honest and legible — readable per-language breakdown + accessible to VoiceOver.

### Shipped (MERGE)
- **One spoken summary for the exposure chart + labeled per-language bars and tip** — `worktree-wf_9ff2030f-d98-23` (best candidate) — build=true integrity=true. Single `.accessibilityElement(children: .ignore)` honest sentence mapped to `selectedLanguages` on the ring, per-card label/value split, numeric `numeric_` test-ids, AND explicit label on the fragmented streak banner.
- **Self-decoding exposure bars: inline per-language flag chips** — `worktree-wf_9ff2030f-d98-24` — build=true integrity=true. Inline per-language flag chips so each bar decodes itself without relying on legend/color alone.

### Parked
- **Ring label + language-card labels + numeric test-ids (proof-of-life VoiceOver variant)** — killed as a dominated duplicate of #23 this gen. Trigger to revisit: if the merged #23 + #24 combination regresses VoiceOver on the ring, OR if a future gen drops the streak-banner labeling, re-extract the lean ring-only labeling approach as a fallback.

### Killed assumptions (do not relitigate)
- A second VoiceOver-labeling idea that only labels the ring + cards + numeric ids is NOT worth shipping alongside #23 — #23 strictly supersedes it (also labels the streak banner, uses proper label/value split instead of one crammed label). Same principles (7, 9, 3); pure redundancy.
- Cramming the entire summary into a single accessibility `label` is inferior to the label/value split — assume label/value split going forward.
- Color/legend-only bar encoding is insufficient (drove the #24 flag-chip direction) — bars must self-decode.
