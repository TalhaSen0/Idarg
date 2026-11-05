# Architecture draft

## Current implementation: Phase 0

`scenes/test/phase_zero.tscn` is the main scene, containing only a composition root and diagnostic UI. No sword, physical controller, gameplay camera, intent classifier, AI, or character is implemented.

- `PhaseZero`: constructs and wires components; owns a duplicate of the tuning Resource for this run.
- `DebugTuning`: typed exported settings; baseline stored under resources/tuning.
- `TuningPanel`: builds editors from Resource property metadata and emits setting_changed.
- `MetricsLogger`: fixed-tick sampling and structured stdout records; emits sampled.
- `DebugOverlay`: displays samples and explicitly marks future metrics unavailable.
- `CollisionLayers`: named layer bits and future query masks, matching project settings.

Communication uses signals and injected references, not deep node paths. Runtime setting changes are session-only; restarting or resetting restores the .tres baseline. Godot file logging persists diagnostics under user://logs/phase_zero.log.

## Planned pipeline (not implemented)

Input -> IntentReader -> SwordMotionPlanner -> PhysicalSwordController -> actual sword pose -> ArmIK -> kinematic BodyAnimation.

Intent data is producer-independent for future AI reuse. The planner receives a replaceable depth strategy (target context + input -> desired depth), applies reach limits and allowed assists, and emits desired motion. Only the physical controller drives the rigid sword. Damage consumes actual blade samples and uses custom previous-to-current sweeps, speed, edge alignment and blade region. Physical blocking/sliding remains independent from damage events.

## Collision allocation

| Layer | Bit mask | Constant | Purpose | Planned mask |
|---|---:|---|---|---|
| 1 | 1 | WORLD | Static test obstacles | Sword bits + BODY |
| 2 | 2 | PLAYER_SWORD | Player physical blade | WORLD + OPPONENT_SWORD + BODY (13) |
| 3 | 4 | OPPONENT_SWORD | Opponent/test blade | WORLD + PLAYER_SWORD + BODY (11) |
| 4 | 8 | BODY | Kinematic physical bodies | WORLD + both swords (7) |
| 5 | 16 | HURTBOX | Damage-only query areas | 0; queried by blade detector |

Damage queries use HURTBOX (16), enable area detection, exclude the owner, and deduplicate contacts per swing/target. Shared BODY/HURTBOX layers require explicit owner filtering; no player/opponent self-hit semantics are implemented yet. All current layers are reserved; Phase 0 creates no collision bodies.

## Debug contract

F1 toggles the current overlay; F2 toggles tuning; F5 restores debug defaults. Future systems must add togglable desired/actual pose, reach envelope, blade samples, contact points, assist cone, force/torque and tracking error views when implemented. Never show fabricated zero combat metrics in their absence.

## Engine/API baseline

Verified executable: 4.7.stable.official.5b4e0cb0f. Existing Forward Plus / D3D12 and built-in Jolt configuration retained. Physics tick defaults to Godot's 60 Hz; any future experimental physics tuning must become Resource-backed and runtime-editable.

Versioned references checked during setup:
- https://docs.godotengine.org/en/4.7/classes/class_resource.html
- https://docs.godotengine.org/en/4.7/classes/class_range.html
- https://docs.godotengine.org/en/4.7/classes/class_control.html
- https://docs.godotengine.org/en/4.7/classes/class_node.html
- https://docs.godotengine.org/en/4.7/classes/class_inputeventkey.html
- https://docs.godotengine.org/en/4.7/classes/class_performance.html
- https://docs.godotengine.org/en/4.7/classes/class_skeletonmodifier3d.html
- https://docs.godotengine.org/en/4.7/classes/class_ikmodifier3d.html
- https://docs.godotengine.org/en/4.7/classes/class_skeletonik3d.html
- https://docs.godotengine.org/en/4.7/classes/class_shapecast3d.html
- https://docs.godotengine.org/en/4.7/classes/class_rigidbody3d.html
- https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html

SkeletonIK3D is deprecated; IKModifier3D has ChainIK3D and TwoBoneIK3D derivatives. Do not choose an IK implementation before Phase 3 validation. Jolt does not support several soft-limit joint properties. ShapeCast3D sweeps along target_position; it alone is not proof of rotational blade coverage. RigidBody3D CCD uses continuous_cd. Verify concrete APIs again before implementing each future system.
