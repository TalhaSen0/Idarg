# Phase 0 validation — 2026-11-06

Engine: 4.7.stable.official.5b4e0cb0f. Scope: diagnostic scaffold only.

- Headless editor import completed successfully.
- Native Forward+ / D3D12 run on NVIDIA GeForce RTX 4060 Laptop GPU: approximately 22 seconds, no runtime errors reported by the Godot tool.
- Screenshot inspected at approximately 1170 x 695: labels and three numeric editors readable, no overlap.
- Programmatic keyboard/mouse input verified independent F1/F2 toggles, opacity 1.0 -> 0.4, F5 restoration to 1.0 while a numeric field had focus, log interval 2.0 -> 0.5, button reset to 2.0, refresh interval 0.2 -> 1.0 -> 0.2.
- Metrics confirmed the changed log cadence: samples at simulation 12.6167 and 13.1333 seconds while configured to 0.5 seconds. Sampling is quantized to fixed physics ticks (up to one tick late due to accumulation).
- Separate clean headless run after bridge removal: 240 process frames with --max-fps 60, exit code 0, no script errors. Log sample: 121 physics ticks / 2.0167 simulation seconds, 60 FPS, 0.325 ms physics CPU. These are empty-scene measurements, not performance budgets.
- Engine-persisted user://logs/phase_zero.log verified on disk. Runtime .tres baseline remains unchanged.
- The temporary Godot MCP bridge is removed from project settings and excluded from Git.

## Not validated

Human keyboard/mouse experience, window resizing, alternate hardware, and all combat/character/assist/feel criteria. No gameplay system exists yet. User playtest approval is pending.

## Known limitations

Runtime debug edits are session-only by design. Performance monitors may update up to a second late. Sampling intervals are quantized to physics ticks. The prior idarg folder contains only ignored generated editor cache/import metadata; import the root project.godot, not the old editor project entry.

The approved parry guarantee still requires a feasibility decision during Phase 4 if finite physical limits and the selected tolerance gate conflict. This is a future design risk, not a Phase 0 implementation claim.
