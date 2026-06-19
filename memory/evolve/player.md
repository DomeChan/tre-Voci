# Evolve Progress — Target: Player screen

Tracks generational evolution of the Player screen (PlayerView + LanguagePicker + scrub/captions + AirPlay route).

## Generation 2

**Target:** Make Player playback honest and scrub-accurate — captions that follow the scrub head, and an output label that names the real route.

### Shipped (MERGE / candidate branches)
- **Honest AirPlay output label** — `evolve/honest-airplay-route` (best candidate this gen) — build=true integrity=true. Shows the real current-route name from the audio session instead of a hardcoded "iPhone" string, so families streaming to Sonos/HomePod see where audio is actually going. P1 honesty fix (#12/#10).

### Parked (with re-evaluation trigger)
- **Scrub-accurate captions** — `worktree-wf_9ff2030f-d98-62` — build=true integrity=true, verdict=REVISE. Recomputes the active lyric line on seek instead of flashing line 0. Real correctness fix (P2 sync-integrity) but came back REVISE, not MERGE. **Trigger:** re-run next gen once the seek->line lookup is cleaned up to MERGE quality; if a scrub regression (line-0 flash / stale caption on seek) is observed, promote this immediately.
- **[toddler-motor] LanguagePicker 44pt tap floor** — killed this gen as the weaker sibling (see below). **Trigger:** revisit in a dedicated toddler-motor / forgiveness-tap pass, OR if the ~30pt-tall picker (LanguagePicker.swift:20) shows real mis-tap pain on cross-cultural songs.

### Killed assumptions (do not relitigate)
- The Player output label was NOT honest — it hardcoded "iPhone" regardless of the actual AVAudioSession route. Assume route name must be read live from the session going forward; do not reintroduce a static device string.
- The LanguagePicker 44pt enlargement is a forgiveness/polish (#8-#9), not a correctness fix. It loses to sync-integrity (P2) and AirPlay-honesty (P1) on principle-severity. Do not re-rank it above a correctness/honesty fix in a future at-most-2 cut — it is a follow-up toddler-motor item, not a primary candidate.
- The LanguagePicker already works on a precise tap and already carries `accessibilityLabel` + `.isSelected`, and only appears for cross-cultural songs — so it is NOT an accessibility/anti-pattern violation, just an ergonomics gap. Do not relitigate it as an a11y blocker.
- Captions previously flashed line 0 on seek (the naive reset-on-seek behavior). Assume seek must recompute the correct line; the line-0 flash is a known-bad baseline, not a candidate behavior.
