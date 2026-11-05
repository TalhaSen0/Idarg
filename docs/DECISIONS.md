# Decision log

## 2026-11-06 — Approved by the developer

- Scope: Phase 0 only until explicit playtest approval. No Phase 1 mechanics.
- Camera: third-person over-the-shoulder. Phase 0 has no gameplay camera.
- Depth: target/lock-on-based automatic depth, behind a replaceable strategy interface. Do not couple the input reader or physical controller to the depth strategy.
- Input: keyboard and mouse only for the initial experiment.
- Half-swording: excluded from the initial version.
- Combat scope: 1v1 only; no multiplayer requirement is implied.
- Success gate: objective technical checks AND explicit subjective feel approval.
- Godot project root: C:/NGames/IdargGodot. Root source documents retain their names and locations. The previous idarg directory only retains ignored generated cache/import metadata.
- Control target: sword; anatomically constrained arms follow the actual physical sword.
- Physical body: long-term goal; the initial character body is kinematic.
- Conditional parry contact guarantee: RMB must be held and BOTH player movement direction and timing must be inside the configurable tolerance cone/window. Within that gate, parry assistance ensures contact. Outside the gate there is zero assistance; a wrong parry fails. Without RMB there is no automatic defense. Cone width and assistance strength are adjustable; timing tolerance is adjustable too.
- AGENTS.md is updated to reflect the explicit parry exception, including its Phase 4 description. Attack assistance does not gain this exception.

## Constraints and unresolved implementation details

- Strength 0 remains fully manual as required by AGENTS.md. The relationship between positive strength and a contact guarantee must be made concrete before Phase 4; this is not permission to quietly weaken the guarantee.
- Contact guarantee must coexist with finite force/torque, reach limits, and no sword teleportation. Physically unreachable contacts cannot be assumed solvable. Phase 4 must expose infeasible cases and obtain a decision if these requirements cannot coexist within the selected gate.
- The 15-degree wrist example in VISION.md is illustrative, not an approved threshold.
- Initial Phase 1 control questions are resolved in the Phase 1 authorization entry below. Target acquisition/switching is excluded; a single movable reference is used.
- Concrete test thresholds below are provisional starting values from the proposed success gate, not evidence of feel or universal physical truth.

## Phase 1 authorization and controls — 2026-11-06

- Phase 0 approved by developer after F1/F2/F5 playtest. Phase 1 is authorized; Phase 2 is not.
- Fixed camera, no free rotation. C cycles rear, side, and shoulder-like presets. The eventual third-person camera decision is unchanged.
- One debug target supplies automatic depth through a replaceable strategy. Keyboard movement is required; no target selection system in this phase.
- RMB/defend takes precedence when both mouse buttons are held. Re-evaluate after playtesting. Intent is diagnostic only until later assistance work.
- Tuning panel must occupy a corner, be translucent and closable while the sword stays visible.
- Phase 1 controls: Tab toggles cursor capture; F2 opens tuning and releases the cursor. Uncaptured mode holds the desired pose while editing. C changes view without changing the desired pose. I/K, J/L, U/O move the debug target forward/back, left/right, up/down. R recenters the desired target only; it never teleports the physical sword.
