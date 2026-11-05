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
- Input precedence when both mouse buttons are held, lock-on acquisition/switching, and camera-look versus sword-input routing remain Phase 1 design questions. Do not silently implement them.
- Concrete test thresholds below are provisional starting values from the proposed success gate, not evidence of feel or universal physical truth.
