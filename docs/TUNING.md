# Tuning

## Phase 0 live parameters

Baseline: res://resources/tuning/debug_tuning.tres. Exported range metadata lives in DebugTuning; the panel reads it instead of duplicating limits. Only diagnostics exist in this phase.

| Property | Default | Editable range | Effect |
|---|---:|---|---|
| refresh_seconds | 0.2 s | 0.1–2.0 s | Overlay sample interval |
| log_seconds | 2.0 s | 0.5–10.0 s | Structured metrics log interval |
| overlay_opacity | 1.0 | 0.2–1.0 | Debug overlay alpha |

Edits take effect during the run. F5 or Reset debug defaults restores the .tres values. Changes do not overwrite the asset. To establish a new baseline, edit the Resource in the Godot Inspector and commit intentionally. F1/F2 toggle overlay/panel independently; metrics continue logging when hidden.

Simulation seconds and physics ticks come from _physics_process; FPS and physics CPU milliseconds come from Performance and can lag by a second. They are diagnostic measurements, not proof of sword feel. Logs use PHASE0_START, PHASE0_METRICS and PHASE0_TUNING prefixes and are persisted by Godot to user://logs/phase_zero.log.

## Future tuning contract

Introduce parameters only with their systems, under resources/tuning and editable at runtime. Future groups: sword mass/length/inertia; PD gains/force/torque caps; depth strategy; reach; damage samples/thresholds; separate attack/parry strength; parry direction cone and timing window. No pretend combat sliders in Phase 0. Defaults are hypotheses, not validated constants. Record units, tested ranges and tradeoffs with each implementation.
