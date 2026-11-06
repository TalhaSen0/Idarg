# Idarg — intent-driven sword combat (Godot)

Medieval two-handed longsword duel experiment: the player drives a **desired sword pose**; a **physics-limited** controller produces the actual rigid-body motion. See **`AGENTS.md`** for non-negotiable design rules and phase plan.

## Requirements

- **Godot 4.7** (project declares `4.7` in `project.godot`).
- **Jolt** physics (configured in `project.godot`).

## Run

Open the folder in Godot and press **Run Project**, or run `scenes/test/contact_lab.tscn` (current main scene).

| Scene | Purpose |
|-------|---------|
| `scenes/test/contact_lab.tscn` | **Default:** Contact Lab — second sword + swept hit detection vs probe |
| `scenes/test/sword_lab.tscn` | Sword Lab — single sword, obstacle, tuning |
| `scenes/test/phase_zero.tscn` | Phase 0 — debug overlay / tuning / metrics only |

## Docs

- **`_PROJECT_STATE.md`** — current phase and next actions
- **`docs/ARCHITECTURE.md`** — systems and collision layers
- **`docs/ROADMAP.md`** — phase gates
- **`docs/PLAYTEST_LOG.md`** — manual checklists
- **`docs/VALIDATION.md`** — automated check summaries

## Controls (labs)

**F1** debug draw · **F2** tuning panel · **F5** restore debug/tuning defaults · **Tab** cursor capture · **C** camera preset cycle · **I/K J/L U/O** move depth reference · **R** recenter reference (does not teleport the physical sword).

Intent labels (telemetry): **LMB** attack, **RMB** defend (defend wins if both held). Phase 2 attack trial: one qualified hit per probe per **fresh LMB press** (see `docs/PLAYTEST_LOG.md`).
