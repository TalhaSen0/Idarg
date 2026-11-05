# PROJECT: Intent-Driven, Physics-Assisted Sword Combat (Godot)

## Language
Talk to the human in Turkish. Code, comments, docs and commit messages in English.

## One-line pitch
A medieval two-handed longsword duel game with Half Sword-like freedom, but
without the goofy parts. Player controls the SWORD (tip position, edge
orientation, motion), not the arm. The game interprets intent (attack / defend)
and executes the anatomical and physical details. Assist must translate the
player's skill into the physical world, never replace it.

## Core design principles (non-negotiable)
1. Control target = sword (6DoF pose + velocity), arms follow via IK.
2. DESIRED motion (from player intent) and ACTUAL motion (from physics) are
   always separate. Weight and resistance come from the gap between them.
   The sword may never teleport to the desired pose; it is pulled by a
   force/torque-limited PD controller.
3. Arms follow the ACTUAL sword pose, not the desired one.
4. The desired sword pose is clamped to a shoulder-centered reach envelope so
   IK never has to solve an impossible/anatomically absurd pose. Torso
   rotation and footwork expand the envelope.
5. Assist helps EXECUTION, not DECISION:
   - Allowed: rotate wrist/edge to align with motion, pull gently toward
     guard poses (Vom Tag, Ochs, Pflug, Alber), small angle/position
     correction if player's motion and timing are inside a tolerance cone.
   - Parry exception (approved 2026-11-06): while RMB is held, if the
     player's movement direction AND timing are inside the configurable
     tolerance cone/window, parry assistance ensures weapon contact.
     Outside that gate there is zero assistance; an incorrect parry fails.
     Without RMB there is no automatic defense. Cone width, timing tolerance,
     and parry strength are tunable. Strength 0 remains fully manual.
     Contact assistance must preserve actual physics, reach, and force/torque
     limits; feasibility and strength semantics require Phase 4 validation.
   - Forbidden: automatic defense without RMB, assistance outside the
     direction/timing gate, or attack assistance that guarantees contact.
   - Attack assist and parry assist have SEPARATE strength parameters
     (0 = fully manual ... 1 = strong). Default values are a starting guess,
     to be tuned by playtest, not treated as truth.
6. Damage detection and physical contact are separate systems:
   - Damage: custom swept detection (multiple sample points along the blade,
     previous-frame to current-frame sweeps), uses speed, edge alignment,
     contact point (forte vs foible/tip).
   - Physical contact: sword vs sword/body blocking and sliding via physics
     bodies.
7. Complexity is added in stages. Body/legs are KINEMATIC at first. Physical
   balance/walking is out of scope until the sword feel is proven fun.
8. We build the feel test first (sword lab without a character), the
   character second.

## Input model (initial proposal, may be revised in GDD)
- LMB held = ATTACK intent. RMB held = DEFEND intent. Neither = neutral/guard.
- Mouse delta drives a virtual sword target on a camera-relative sphere/region
  around the player. Mouse velocity direction + speed classify the motion
  (cut diagonal/horizontal, overhead, thrust). Thrust: tip follows motion
  direction. Cut: wrist auto-rotates so the true edge leads.
- Depth (forward/back) is the hard 2D-to-3D problem. Propose 2-3 options in
  the GDD (lock-on based auto depth, scroll wheel, mouse-speed based) and ask
  the human to choose. Do not silently decide.

## Tech rules
- Godot 4.x, typed GDScript only (static typing everywhere). No C# unless asked.
- BEFORE using any Godot API (IK, SkeletonModifier3D, Jolt joint features,
  ShapeCast3D, CCD settings) verify it against the documentation of the
  installed Godot version. Never assume Godot 3 vs 4 API names. If unsure,
  say so and ask.
- Physics code in _physics_process. Fixed tick, no frame-rate-dependent logic.
- No magic numbers: every tunable lives in a Resource (.tres) under
  res://resources/tuning/ and is editable at runtime via a debug panel.
- Every system gets a debug visualization (toggle with a key): desired vs
  actual sword pose, reach envelope, sample points, contact points, assist
  cone, applied force/torque, tracking error.
- Small, single-responsibility scripts. Signals for communication; no deep
  node-path coupling.
- Collision layers/masks documented in docs/ARCHITECTURE.md and defined as
  named constants.
- Commit after each working step with a clear message. Never leave the project
  in a non-running state at the end of a task.

## Pipeline (architecture)
Input + Intent (mouse, buttons, positions)
 -> IntentReader (classifies attack type / defend / neutral)
 -> SwordMotionPlanner (desired pose, velocity, path; applies reach envelope,
    guard pull, assist)
 -> PhysicalSwordController (PD on position + orientation, force/torque
    limits, collisions)
 -> Actual sword pose (physics result)
 -> ArmIK (hands follow actual hilt grip points)
 -> BodyAnimation (torso twist, footwork, hit reactions) [kinematic first]

Enemy AI later produces the SAME intent objects as the player, so both use the
same pipeline.

## Folder structure
res://
  AGENTS.md
  docs/        GDD.md, ARCHITECTURE.md, TUNING.md, DECISIONS.md,
               PLAYTEST_LOG.md, ROADMAP.md, ASSET_SPEC.md
  assets/      models/weapons, models/characters, animations, audio
  scenes/      test/ (sword_lab.tscn, contact_lab.tscn, duel_lab.tscn),
               characters/, weapons/, ui/
  scripts/     core/ input/ sword/ character/ combat/ ai/ debug/
  resources/   tuning/ (*.tres), intent/
  tests/       headless/unit tests where meaningful (math, envelope clamp,
               intent classification)

Suggested scripts: intent_reader.gd, intent.gd (data class),
sword_motion_planner.gd, reach_envelope.gd, guard_poses.gd,
physical_sword_controller.gd (PD), sword_body.gd, blade_hit_detector.gd,
arm_ik_driver.gd, debug_overlay.gd, tuning_panel.gd.

## Sword asset spec (for whoever makes the model)
- Origin at the primary (rear) grip center. Blade along a single documented
  axis, edge normal along another. Document axes in ASSET_SPEC.md.
- Marker3D children: GripMain, GripFront, Pommel, Crossguard, BladeBase,
  BladeMid, Tip. Hit sample points are derived from these.
- Separate simple collision shape (not the visual mesh).
- Realistic mass/length for a longsword (~1.2-1.4 kg, ~1.1-1.3 m); mass
  distribution/inertia configured in tuning, not hardcoded.

## Working agreement (how you work with me)
- Work ONE PHASE at a time. At the start of a phase, restate the goal and
  acceptance criteria. At the end, list what was done, what is untested, and
  known problems.
- You cannot judge "feel". Therefore every phase must end with: (a) a runnable
  scene, (b) tunable parameters in the debug panel, (c) objective metrics
  logged where possible (tracking error, overshoot, time-to-target, missed
  hits per 100 swings), (d) a short list of specific things I should try by
  hand and what to report back.
- If a requirement is ambiguous or a design choice has real tradeoffs, present
  2-3 options with a recommendation and wait for my choice. Record decisions
  in DECISIONS.md.
- Don't add features outside the current phase. Don't refactor unrelated code.
- Time estimates are guesses; don't promise durations.

## Phases (each needs my playtest approval before the next)
Phase 0  Project setup: folders, docs skeleton, GDD draft, ARCHITECTURE draft,
         debug overlay, tuning panel scaffolding. Ask me the open questions.
Phase 1  Sword Lab (no character): a physical sword driven by mouse via PD.
         Test A free control (tracking, no runaway at high mouse speed).
         Test B hit a hard object, controller recovers stably.
Phase 2  Contact Lab: second sword (static/scripted). Test C swords block and
         slide. Custom swept damage detection with blade sample points.
Phase 3  Character kinematic body + ArmIK following the actual sword pose +
         reach envelope + torso twist. No physics on legs.
Phase 4  Intent layer: attack assist (edge alignment, thrust following,
         bounded target magnetism) and defend assist (bounded, cone-limited,
         conditional contact guarantee inside the approved gate). Slider per assist.
Phase 5  Hit reactions, stagger, blocked-sword pushback (faked via animation or
         impulse on body), damage/death.
Phase 6  Enemy AI producing the same Intent objects. Basic duel loop.
Phase 7  Polish, audio, camera, optional partial physical body.

## Definition of done for the whole experiment
A stranger can pick up the controls in minutes, a correct parry intent
usually works, a wrong one fails, the sword feels heavy, and nothing looks
goofy (no impossible arm poses, no blade-flat hits that should be edge hits).