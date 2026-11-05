# Phase 0 validation â€” 2026-11-06

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

# Phase 1 validation — 2026-11-06

Engine: 4.7.stable.official.5b4e0cb0f, built-in Jolt, 60 Hz physics baseline.

Repeatable command (substitute the local Godot executable):

```powershell
& 'C:\Users\TalhaSen\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe' --headless --path 'C:\NGames\IdargGodot' --script res://tests/phase_one_checks.gd --fixed-fps 60
```

Automated default-tuning results:
- 100 alternating raw mouse spikes: finite, rate-limited desired position.
- 100 rapid desired-position/orientation reversals: no runaway or force/torque cap violations.
- Free recovery meets <4 cm grip error and <3 deg orientation error.
- 20/20 scripted obstacle trials registered physical contact; all settled after withdrawal within the 4-second test allowance.
- Maximum observed speed: 2.82345 m/s. Maximum grip tracking error across free/contact tests: 0.62597 m (includes intentional blocked-target error).
- Worst withdrawal-to-settle time: 1.28333 s, including 0.3 s sustained settling. Contact-release recovery logger: 1.15 s in these trials.
- Positive overshoot along the scripted 0.4 m step: effectively zero (1.53e-6 m, below useful physical precision). This is one controlled step, not proof for all tunings/motions.
- Quaternion +/-179 degree wrap uses the short arc. Target-depth min/max clamps verified.
- Exit code 0, failures=[]; tests run against actual Jolt bodies, not mocked integration.

Native D3D12/Forward+ verification:
- Rear, side and shoulder-like cameras inspected; side camera moved to the left to avoid the obstacle hiding the blade.
- Orange desired and cyan actual outlines, floor, obstacle and depth reference visible.
- Mouse input changed desired/actual poses; I moved target Z and resulting hilt depth.
- Both mouse buttons produced DEFEND.
- Corner panel opened/closed. Position Gain changed 100 -> 150 via input and returned to 100 with F5. A focused field did not prevent reset.
- Runtime mass changed to 1.5 kg and blade length to 1.05 m; body mass and Tip marker (1.17 m) updated without runtime errors. Runtime changes did not alter the baseline .tres.
- Runtime error list empty when test sessions stopped. The temporary MCP bridge is removed from project settings after testing.

Limitations: default tuning and scripted paths only; no exhaustive parameter-range or high-speed rotational tunneling proof. No damage/sword-vs-sword tests, character, anatomical IK, attack/parry assist or human feel evaluation. Target X/Y are reference only. A single box collider omits protruding guard/pommel contact. Window-resize and alternate-resolution usability still require human testing. Existing editor serialization changes to phase_zero.tscn are preserved.

# Phase 2 validation - 2026-11-06

Engine rechecked: 4.7.stable.official.5b4e0cb0f; built-in Jolt, 60 Hz.

Run the installed Godot console executable with:

```
--headless --path C:/NGames/IdargGodot --script res://tests/phase_two_checks.gd --fixed-fps 60
```

Final result: failures=[], exit code 0.
- 20/20 physical trials: real Jolt contact, blade did not cross the opponent at intersection height, sustained sliding, stable withdrawal recovery.
- Maximum slide: 0.449446 m; each path requires >0.25 m and >30 contact ticks.
- 100/100 known translation crossings detected. Zero duplicate events on same-trial recrossing.
- 100 nearby noncrossing paths: zero false positives.
- Pure 90-degree rotation detected a small target on the arc, away from the straight endpoint chord.
- Flat, slow and backward-tip motions do not score; forward-tip qualifies. Forte/foible weights differ. Excluded owner hurtbox RID does not emit hits.
- All numeric/vector panel fields match their underlying tuning values. Fixed a prior 0.95 m blade-length display rounding issue by changing editor step only.

The independent translation oracle uses a stationary known box: endpoints outside its X interval, crossing it while blade span covers its Y interval and Z is inside. These are detector trajectory tests, not claims the controller reaches those one-frame speeds. Physical tests use force-driven bodies.

The initial physical setup crossed the opponent while orienting from spawn. Corrected staging first moves laterally into clear space, then orients and approaches. Tests inspect blade position at intersection height instead of assuming the hilt cannot cross a plane when the blade rotates. No controller retuning or teleport was used to pass tests.

Native runtime checks:
- Rendered scene and sample/contact overlays inspected.
- Actual physical sword crossing the green probe with LMB generated one cut event (observed score ~5.31). Recrossing while held kept accepted count at one and suppressed repeated candidates.
- RMB toggles while LMB remains held do not rearm. Panel/cursor mode cancels armed damage and does not rearm until fresh LMB. Trial ID stayed 1 through these transitions and became 2 on fresh press.
- Opponent rotation edited -90 -> -60 degrees via UI; F5 restored both data and fixture to -90. Correct degree bounds verified.
- Runtime error lists empty on shutdown. Temporary MCP bridge removed.
- Phase 1 regression suite passes: 100 reversals, 20 obstacle contacts, original 1.28333 s maximum withdrawal recovery. Controller defaults unchanged.

Limits: human feel, moving hurtboxes, exhaustive tuning/angle/speed combinations, dense multiple hurtboxes, exact swept-mesh coverage, extreme angular motion between ticks, character and parry assist remain unverified. Probe is intentionally nonblocking; no HP/death. Scores/tolerances are provisional. The developer's pre-existing phase_zero.tscn editor serialization change is preserved and excluded from this implementation commit.
