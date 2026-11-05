# Tuning

## Phase 0 baseline parameters (historical)

Baseline: res://resources/tuning/debug_tuning.tres. Exported range metadata lives in DebugTuning; the panel reads it instead of duplicating limits. Only diagnostics exist in this phase.

| Property | Default | Editable range | Effect |
|---|---:|---|---|
| refresh_seconds | 0.2 s | 0.1–2.0 s | Overlay sample interval |
| log_seconds | 2.0 s | 0.5–10.0 s | Structured metrics log interval |
| overlay_opacity | 1.0 | 0.2–1.0 | Debug overlay alpha |

Edits take effect during the run. F5 or Reset debug defaults restores the .tres values. Changes do not overwrite the asset. To establish a new baseline, edit the Resource in the Godot Inspector and commit intentionally. F1/F2 toggle overlay/panel independently; metrics continue logging when hidden.

Simulation seconds and physics ticks come from _physics_process; FPS and physics CPU milliseconds come from Performance and can lag by a second. They are diagnostic measurements, not proof of sword feel. Logs use PHASE0_START, PHASE0_METRICS and PHASE0_TUNING prefixes and are persisted by Godot to the configured project log (originally user://logs/phase_zero.log; now user://logs/sword_lab.log).

## Future tuning contract

Introduce parameters only with their systems, under resources/tuning and editable at runtime. Future groups: sword mass/length/inertia; PD gains/force/torque caps; depth strategy; reach; damage samples/thresholds; separate attack/parry strength; parry direction cone and timing window. No pretend combat sliders in Phase 0. Defaults are hypotheses, not validated constants. Record units, tested ranges and tradeoffs with each implementation.

## Phase 1 live settings

Baseline: resources/tuning/sword_tuning.tres. The SwordTuning export metadata defines editable ranges/steps. F2 opens the translucent corner panel, F5 resets, Tab toggles cursor/control. Scroll to reach the full list. Values are session-only. Editing collider dimensions or obstacle position can create an overlap; do those experiments with the sword clear of the obstacle.

| Group | Main defaults and units | Purpose |
|---|---|---|
| Controller | position gain 100 s^-2, damping 20 s^-1; rotation gain 120 s^-2, damping 22 s^-1 | Follow speed and damping, implicitly scaled for the physics step |
| Caps | 100 N, 12 Nm | Total force including support; torque magnitude |
| Sword | 1.3 kg, 0.16 transverse / 0.004 axial kg m^2, COM Y=0.32 m | Physical properties, manually tunable |
| Geometry | 0.95 m blade, 0.05 m width, 0.012 m thickness, 0.24 m grip, 0.26 m guard | Simple mesh, markers and collision |
| Contact | friction 0.4, zero bounce | Sliding/resistance baseline |
| Input | 0.003 m/pixel, +/-1.1 m horizontal, +/-0.65 m vertical | Mouse mapping and desired workspace |
| Desired rate | 3 m/s, 4 rad/s | Limits desired motion, never overwrites actual speed |
| Orientation | -45 deg rest pitch, 35 deg displacement tilt | Provisional pitch/roll mapping |
| Depth | target Z +0.75 m, clamped [-0.65, 0.8] m | Replaceable target-depth strategy |
| Target | 0.6 m/s keyboard movement; editable start/bounds | Debug reference; R applies start |
| View/lab | FOV 52 deg, three positions/look-at, obstacle size/position | Live camera and obstacle setup |
| Diagnostics | 0.2 s refresh, 2 s log interval | Overlay and log cadence |
| Settling | <0.04 m, <3 deg, <0.15 m/s for 0.3 s | Recovery detection, not a universal feel threshold |
| Vectors | force 0.008 m/N, torque 0.06 m/Nm | Debug arrow scale |
| Panel | alpha 0.75, width 360 px, height 0.65 of viewport | Corner panel layout |

Low force caps can be insufficient even to hold the sword against gravity. Broad editable ranges are experiments, not all validated combinations. Return to defaults if the sword falls or oscillates. R never teleports; restart the scene for a clean initial spawn if an extreme tuning combination traps it.

Logs: user://logs/sword_lab.log. SWORD_METRICS contains current/RMS/peak grip error, angle error, speeds, applied force/torque, contact entries and latest recovery; -1 recovery means no completed recovery yet. Recovery starts when contact is lost and includes the sustained settling window. The scripted test's withdrawal-to-settle time starts earlier, at the withdrawal command. Contact entries may count repeated recontacts; they are not damage events. Runtime peak error is not overshoot; step overshoot is measured separately by the repeatable test.

Static floor dimensions, mesh decorative dimensions/colors, UI padding and debug cross sizes are presentation constants, not physical-control tuning. No attack/parry strengths are exposed until those systems exist.

## Phase 2 settings

Contact Lab loads resources/tuning/contact_tuning.tres, extending the unchanged Phase 1 defaults. F2 lists contact fields first; previous controller fields follow. F5 resets the active asset. Runtime edits remain session-only.

| Setting | Default | Meaning |
|---|---|---|
| opponent_position | (-0.2, 1.75, -0.45) m | Static sword grip |
| opponent_rotation_degrees | (0, 0, -90) deg | Horizontal blade |
| opponent_friction | 0.3 | Physical friction |
| hurtbox_position / size | (-0.8, 1.6, -0.5) / (0.15, 0.7, 0.5) m | Nonblocking probe |
| blade_samples | 25 | BladeBase through Tip |
| sweep_radius | 0.02 m | Swept capsule radius |
| rotation_step_degrees | 5 deg | Rotational subdivision angle |
| max_rotation_steps | 36 | Cost cap; capped frames logged |
| query_max_results | 16 | Area results per query |
| minimum_hit_speed | 0.25 m/s | Slow contact rejection |
| minimum_edge_alignment | 0.65 | Edge directional cosine |
| minimum_tip_alignment | 0.75 | Forward tip directional cosine |
| tip_start_fraction / forte_end_fraction | 0.85 / 0.35 | Region boundaries |
| forte / foible / tip weight | 0.6 / 1.0 / 1.2 | Score weighting |
| score_scale | 1.0 | Diagnostic scale, not HP |

Move/reorient fixtures only while the sword is clear; editing them into the sword creates overlaps. F5 also resets fixture positions. History is invalidated on geometry/fixture edits. Detection tolerances and score weights are provisional.

The active project log is user://logs/contact_lab.log, also when running older lab scenes. CONTACT_METRICS and BLADE_HIT supplement SWORD_METRICS. Report tuning, camera, and whether the issue is physical blocking, a missing candidate, or a flat/slow rejection.
