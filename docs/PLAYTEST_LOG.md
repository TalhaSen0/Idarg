# Playtest log

## Template

- Date / phase / commit / Godot version:
- Tester / hardware / rendering configuration:
- Scene and tuning values:
- Scenario and number of repetitions:
- Expected result / observed result:
- Objective metrics and log location:
- Control clarity / weight / replay desire (1–5, if applicable):
- Count and description of "not what I intended" actions:
- ANTI_GOOFY status per applicable item: solved / partially solved / not yet testable:
- Regressions / unresolved issues:
- Decision: repeat / redirect / approve next phase (developer only):

## 2026-11-06 — Phase 0 handoff

Developer approval: pending. Combat feel is not evaluated in this phase.

Manual checklist:
1. Import the root project.godot and run with F6 on phase_zero.tscn or the editor Run Project button. F5 is Godot's editor Run shortcut and the running lab's reset shortcut.
2. Confirm the Phase 0 label, increasing physics tick count and no errors.
3. Toggle F1 and F2 independently, including while a numeric field has focus.
4. Change refresh_seconds, log_seconds and overlay_opacity; verify refresh cadence, log cadence and visible alpha change.
5. Use Reset debug defaults and F5; verify baseline values return. Restart and verify no runtime edits persisted.
6. Resize the window and confirm fields remain usable. Report clipping or unreadable text.
7. Inspect user://logs/phase_zero.log (Project > Open User Data Folder) for structured metrics and tuning events.

ANTI_GOOFY status: all eleven symptom/feeling items and the three preservation goals are not yet testable. No sword, arms, locomotion, parry or combat exists. None is marked solved by an empty scene.

Automated evidence is recorded in VALIDATION.md after checks finish.
