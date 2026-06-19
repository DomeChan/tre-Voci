# evolve-portable

A shareable, project-agnostic version of the `evolve` autonomous improvement loop. Contains **zero**
company-, product-, framework-, or path-specific knowledge — all of that is pushed into two config
files you fill in once per repo.

## What it does

Runs a generational improvement loop on any target in any repo:

```
FRAME → IDEATE (parallel, per-lens) → KILL (red-team) → ALLOCATE → EXECUTE (parallel, worktrees)
      → VALIDATE → VALIDATION GATES (G1 vision / G2 regression / G3 numeric-truth) → REPORT + PERSIST → MERGE GATE
```

Built entirely on Claude Code primitives: the `Agent` tool with `isolation: "worktree"`, the auto-memory
system, and `/loop` for multi-generation runs. The distinguishing feature vs. plain evolver-style loops
is a **red-team KILL phase** that murders weak ideas before any code is written.

## Files

| File | Purpose | You edit? |
|------|---------|-----------|
| `SKILL.md` | The generic orchestrator. Reads the two config files and runs the loop. | No |
| `VALUE_FRAMEWORK.template.md` | Template for your principles / personas / domain lenses. | Copy → `VALUE_FRAMEWORK.md`, fill in |
| `SURFACES.template.md` | Template for your build / capture / token-path commands per surface. | Copy → `SURFACES.md`, fill in |

## One-time setup (per repo)

```bash
cd <your-skill-dir>/evolve-portable
cp VALUE_FRAMEWORK.template.md VALUE_FRAMEWORK.md   # then fill in §1 principles + §2 personas
cp SURFACES.template.md        SURFACES.md          # then fill in the adapter columns for your surfaces
```

Optionally point the design-audit / root-cause delegate columns in `SURFACES.md` at agents your project
already has. If you have none, the loop falls back to generic prompts.

If `VALUE_FRAMEWORK.md` / `SURFACES.md` don't exist, the FRAME phase stops and tells you to run setup.

## Run it

```
Read .claude/skills/evolve-portable/SKILL.md
Read .claude/skills/evolve-portable/VALUE_FRAMEWORK.md
Read .claude/skills/evolve-portable/SURFACES.md

Run /evolve-portable on: <target>
Persona: <a key from your VALUE_FRAMEWORK §2, or "none">
Surface: <a key from your SURFACES.md>
Fitness: <one-sentence falsifiable success signal — frozen evaluator cmd for code, G1/G2/G3 for UI>
Lenses: <3-6, ≥1 value lens and ≥1 reference lens>
Generations: 1
Merge: manual
```

Multi-generation: wrap in `/loop`.

## License / provenance

Loop architecture inspired by [evolver](https://github.com/eranshir/evolver). This portable adaptation
is engine-only and carries no proprietary content — safe to share.
