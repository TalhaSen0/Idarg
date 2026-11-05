# Architecture draft

## Historical baseline: Phase 0

`scenes/test/phase_zero.tscn` was the Phase 0 main scene, containing only a composition root and diagnostic UI. No sword, physical controller, gameplay camera, intent classifier, AI, or character is implemented.

- `PhaseZero`: constructs and wires components; owns a duplicate of the tuning Resource for this run.
- `DebugTuning`: typed exported settings; baseline stored under resources/tuning.
- `TuningPanel`: builds editors from Resource property metadata and emits setting_changed.
- `MetricsLogger`: fixed-tick sampling and structured stdout records; emits sampled.
- `DebugOverlay`: displays samples and explicitly marks future metrics unavailable.
- `CollisionLayers`: named layer bits and future query masks, matching project settings.

Communication uses signals and injected references, not deep node paths. Runtime setting changes are session-only; restarting or resetting restores the .tres baseline. Godot file logging persists diagnostics under user://logs/phase_zero.log.

## Full pipeline (partially implemented in Phase 1)

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

## Current implementation: Phase 1

Main scene: scenes/test/sword_lab.tscn. No character, damage, AI, attack assist, parry assist or second sword.

- SwordLab is the composition root and fixed-tick orchestrator. It builds the simple floor/obstacle/camera and wires UI signals.
- LabInput accumulates relative mouse events; SwordMotionPlanner consumes them on physics ticks. RMB wins over LMB; intent is telemetry only. Cursor mode clears motion and holds the target so editing never drives the sword. First capture motion is discarded to avoid cursor-warp jumps.
- SwordMotionPlanner maintains raw goal and rate-limited desired pose, velocity and angular velocity. Mouse screen-right/up directions are projected and normalized onto the lab X/Y plane; target-based depth supplies world Z. This keeps lateral control usable from the side view, though screen-space motion is foreshortened there. Camera cycling never rewrites goal or desired pose.
- DepthStrategy is an injected interface; TargetDepthStrategy computes clamp(target.z + offset, min, max). Target X/Y are visible debug reference coordinates and intentionally do not attract the blade. There is no contact magnetism.
- PhysicalSwordController computes implicit-PD-scaled position and orientation feedback with shortest-path quaternion error. It applies central force and world torque with explicit caps. Position feedback is measured at the center of mass, while displayed position error is at the grip origin. Gravity compensation counts against the force cap. Actual velocity supplies damping; desired velocities are separately measured, with no velocity feedforward in this baseline. Actual transform/velocity is never assigned after initial spawning.
- SwordBody only snapshots solver contact positions in _integrate_forces. All control force application, planning and metrics run in _physics_process. The read-only contact callback does not integrate or drive physics.
- SwordVisual creates a deliberately simple mesh, markers and one separate box collider. The guard/pommel visual protrusions have no additional collision shapes in Phase 1.
- LabDebugDraw renders desired/actual outlines, target region (not anatomical reach), reference marker, contact crosses and force/torque/error vectors.
- LabMetrics logs grip error, angular error, RMS/peak error, actual/desired speeds, force/torque, obstacle entries and recovery after contact release. Sustained settling is required. The standalone test additionally measures step overshoot and withdrawal-to-settle time.
- LabPanel edits a per-run duplicate of SwordTuning. Geometry changes rebuild the mesh/collider/markers at a physics tick; mass, inertia, camera and obstacle edits are applied without teleporting the sword. Target Start edits apply on R. No Resource is saved by runtime edits.

Collision layers retain the existing named allocation. WORLD is used by floor/obstacle; PLAYER_SWORD by the rigid sword. Damage layers remain unused. Built-in Jolt, continuous_cd=true, zero bounce, custom COM/inertia, and explicit damping are configured. A 60 Hz default physics tick is the validation baseline.

Additional 4.7 references verified before implementation:
- https://docs.godotengine.org/en/4.7/classes/class_quaternion.html
- https://docs.godotengine.org/en/4.7/classes/class_camera3d.html
- https://docs.godotengine.org/en/4.7/classes/class_input.html
- https://docs.godotengine.org/en/4.7/classes/class_immediatemesh.html
- https://docs.godotengine.org/en/4.7/classes/class_basematerial3d.html
- https://docs.godotengine.org/en/4.7/classes/class_physicsdirectbodystate3d.html
- https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html

Force/torque APIs are used every physics tick, not impulse APIs. CCD is not a guarantee of arbitrary rotational collision coverage; Phase 2 must validate that separately.
