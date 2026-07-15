# Product

## Register

product

## Platform

adaptive

Currently iOS-only in practice — the shipped app, CLAUDE.md, and the PRD's MVP scope all target iPhone/iPad exclusively, with Android explicitly listed as a non-goal. Platform is recorded as `adaptive` because Android is now on the roadmap; treat iOS/HIG as the primary, proven surface today and read `reference/android.md` conventions only when Android work actually starts. This is a forward-looking field, not a claim that Material 3 guidance applies to the current codebase.

## Users

Parents in trilingual households raising a toddler (the founding case: Italian father, Mandarin-speaking mother, English-language school) who want their child to keep absorbing all three home languages without adding another screen to stare at. The app is opened for seconds at a time — pick a song, tap play, put the phone down — while the actual listening happens through a household speaker (Sonos/HomePod via AirPlay 2) in whatever room the family is in. The job to be done is fast, low-friction content selection, not content consumption on the device itself.

## Product Purpose

Tre Voci helps a trilingual toddler maintain exposure to Italian, Mandarin, and English through nursery rhymes and songs, exploiting the fact that many beloved melodies already exist natively in all three languages (Frère Jacques / Fra Martino Campanaro / 两只老虎 / Are You Sleeping). Playing the same melody back-to-back in a single session lets a 2-year-old absorb phonological patterns and vocabulary across all three languages at once. Success is a screen that gets used for seconds, not minutes — the app's job ends the moment audio starts streaming to the room.

## Positioning

The same tune already exists as a beloved children's song in Italian, Mandarin, and English — no one else sequences all three back-to-back as one deliberate cross-cultural listening session.

## Brand Personality

Warm and tactile, the way a well-loved children's book is warm — grounded in the cream/bark/coral palette already in the code rather than anything glossy or synthetic. Calm and trustworthy: no gamification pressure, no manufactured urgency, nothing that asks a tired parent for more attention than a two-second glance. Playful and musical in its motion and voice (the bilingual splash taglines, the gentle breathing pulse on the player) without tipping into cartoonish. Quietly premium — considered and crafted like a well-made physical object for the home, not mass-market edtech.

## Anti-references

Not a generic edtech/kids app: no bright primary-color cartoon mascots, no badges, streaks, or engagement-loop pressure mechanics. Not a cold minimalist SaaS product — warmth is load-bearing, not decorative. And critically, not screen-hungry or attention-grabby in any form: no autoplay-into-next, no infinite scroll, no notification nudges. This isn't a style preference — it's the product's stated philosophy (README: "no analytics, no tracking, no engagement optimization, no notifications... removes harm vectors") and every visual and interaction decision should reinforce it, not just the copy.

## Design Principles

The screen is a launcher, not a destination — every decision should get the parent back to the room faster, not hold them on the device longer. Warmth is expressed through tone and texture (color, type, gentle motion), never through gamification. The three language colors (Italian green, Mandarin red, English blue) are a consistent visual grammar across every surface — meaningful, never decorative. Design for the real use context: a tired, one-handed parent in a dim room at bedtime, not a bright-desk power user. Calm is a feature — the anti-dark-pattern promise has to be visible in the interface itself, not just true in the code.

## Accessibility & Inclusion

Target an AAA-leaning contrast bar, above the WCAG AA + 44×44pt tap-target baseline CLAUDE.md already requires — legibility has to hold up for a tired parent glancing at a dim screen at bedtime, one thumb, low light. Full `accessibilityReduceMotion` support is required everywhere motion appears (already the pattern in the code). Parent-facing copy should use Dynamic Type via `Font.nunito(weight:size:relativeTo:)` rather than fixed sizes wherever legibility matters.
