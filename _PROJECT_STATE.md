# Project state (living)

Last updated: 2026-11-06 (align with `docs/ROADMAP.md` if they diverge).

## Automated checks (local)

- **Phase 2 headless** (`res://tests/phase_two_checks.gd`, `--fixed-fps 60`): re-run **2026-11-06**, exit code **0**, `PHASE2_TEST_RESULT` reported `failures=[]` (20/20 physical trials, sweep oracle passes). Use your installed **Godot 4.7 console** executable; see command in `docs/VALIDATION.md` (Phase 2 section).
- **Phase 1** suite remains `res://tests/phase_one_checks.gd` (documented in `docs/VALIDATION.md`).

## Engine and entry

- **Godot:** 4.7 (see `project.godot` → `config/features`).
- **Physics:** Jolt (`project.godot` → `[physics]`).
- **Default run scene:** `res://scenes/test/contact_lab.tscn`.

## Phase authorization (gates)

| Phase | Implementation | Developer gate |
|-------|----------------|----------------|
| 0 | Done | Approved |
| 1 | Done | Approved for progression (feel notes open in `DECISIONS.md`) |
| 2 | Done (Contact Lab + swept hit detection lab) | **Approved (2026-11-06)** — see `docs/PLAYTEST_LOG.md` |
| 3 | Not started | **Authorized to implement** — kinematic body + ArmIK + reach envelope (no physical legs yet) |

## What exists in code (high level)

- **Sword Lab:** `scenes/test/sword_lab.tscn` — mouse-driven desired pose, PD-limited rigid sword, metrics/debug.
- **Contact Lab:** `scenes/test/contact_lab.tscn` — second static sword, physical contact, green hurtbox probe, `BladeHitDetector` diagnostics.
- **Phase 0 diagnostic:** `scenes/test/phase_zero.tscn` — overlay/tuning/logging scaffold.
- **Docs:** `docs/ARCHITECTURE.md`, `docs/GDD.md`, `docs/DECISIONS.md`, `docs/PLAYTEST_LOG.md`, `docs/VALIDATION.md`.

## Open items (from decision log / roadmap)

- Phase 1 **feel** notes remain open: broad-face strikes, perceived slowness; no mouse acceleration added by explicit deferral.
- Phase 2 **manual approval** recorded in `docs/PLAYTEST_LOG.md` (2026-11-06 entry). Full checklist ratings were deferred; guard/pommel collision remains a known lab simplification.
- Phase 4 **parry assist** feasibility vs finite force/torque limits remains a documented future risk (`docs/VALIDATION.md`, `docs/DECISIONS.md`).

## Next step when resuming work

1. **Phase 3 — Character / IK lab (authorized):** add a runnable **`character_lab.tscn`** (or equivalent) with a **kinematic** body proxy, **Skeleton3D** + documented IK choice (verify Godot 4.7 docs before wiring), **ArmIK** driving hand bones to **actual** sword grip markers, plus **reach envelope** clamp and **torso twist**. No physical legs; keep sword pipeline unchanged.
2. Keep **Contact Lab** and **Sword Lab** runnable; do not remove Phase 1–2 tuning resources.
3. Re-run automated suites after substantive physics/input changes: `tests/phase_one_checks.gd`, `tests/phase_two_checks.gd` (see `docs/VALIDATION.md`).
