# Playtest log

## Template

- Date / phase / commit / Godot version:
- Tester / hardware / rendering configuration:
- Scene and tuning values:
- Scenario and number of repetitions:
- Expected result / observed result:
- Objective metrics and log location:
- Control clarity / weight / replay desire (1â€“5, if applicable):
- Count and description of "not what I intended" actions:
- ANTI_GOOFY status per applicable item: solved / partially solved / not yet testable:
- Regressions / unresolved issues:
- Decision: repeat / redirect / approve next phase (developer only):

## 2026-11-06 â€” Phase 0 handoff

Developer approval: received. Developer confirmed F1/F2/F5 work. Feedback: panel occupied the window; Phase 1 must use a translucent, closable corner panel. Combat feel was not evaluated.

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

## Phase 1 handoff — 2026-11-06

Developer approval: pending. Automated results are in VALIDATION.md. Main scene: sword_lab.tscn.

1. Run the root project. Confirm the floor, sword, orange desired outline, cyan actual outline, yellow reference and brown obstacle. Report visibility problems and screen resolution.
2. Move the mouse slowly in the clear space left of the obstacle, then stop. Report lag, drift and whether the actual blade settles onto the target. Tab releases/captures the cursor.
3. Reverse direction sharply several times, then stop. Report runaway motion, persistent wobble and control clarity (1–5). Automated 100-reversal evidence does not replace human feel.
4. Press C through all three views. Report which best exposes the blade and whether side-view input feels understandable. Camera switches must not move the target by themselves.
5. Hold I/K to move the reference forward/back; J/L moves it left/right, U/O up/down. Report whether depth changes feel predictable. Only Z drives depth; X/Y must not automatically aim the sword at the marker. R restores the reference and desired goal via normal physical tracking.
6. From the rear view, steer the blade right into the brown obstacle, hold briefly, then pull left into free space. Repeat at different heights/angles. Report pass-throughs, sustained jitter, stuck states, and displayed recovery time. For a formal gate run, record 20 attempts.
7. Open F2, change Position Gain from 100 to 150, close the panel and repeat slow motion/contact. Compare tracking and weight. Change Position Damping independently. Restore with F5. Report whether the panel obstructs the sword and whether the mouse ever drives the sword while adjusting fields.
8. Hold LMB, RMB, then both: ATTACK, DEFEND, DEFEND should appear. No assistance should occur. Confirm whether defend priority should remain or be revisited.
9. Toggle F1 to judge the physical blade without debug outlines. Rate control clarity, perceived weight and desire to replay (1–5); describe every "I did not intend that" action. Report chosen tuning values, view and log excerpt with issues.

ANTI_GOOFY status:
- Flat hit despite intended edge/tip: not yet testable (no intent classification/damage alignment).
- Unexplained slow swings: partially addressed (bounded PD/rate limits and force/error telemetry); feel pending.
- Aimed spot missed: partially addressed by explicit desired/actual display; no target magnetism; human assessment pending.
- Intended stab goes sideways: not yet testable as an intent-recognition requirement.
- Impossible arm bends, unreachable anatomical pose, goofy walking: not yet testable (no character).
- Correct parry lost to wrist error: not yet testable (no opponent sword or assist).
- Unforgiving/not-where-I-put-it control: partially addressed by tunable mapping/controller; feel pending.
- "I did not intend that": human assessment pending, not marked solved.
- Freedom without absurd outcomes: partially addressed by bounded desired region/rates and capped physical drive; human assessment pending.
- Preserve weight/momentum: physical body implemented, subjective weight unverified.
- Preserve angle/timing freedom: partial, provisional pitch/roll mapping, no independent full manual orientation controls.
- Preserve believable clashes: hard-obstacle contact verified; sword clashes deferred to Phase 2.

## Phase 1 approval and feedback - 2026-11-06

Developer authorized Phase 2 after brief playtesting. Sword seems to strike with its broad/thick face and feels somewhat slow; hard to judge without fuller game context. Mouse acceleration was explicitly deferred. Existing behavior is preserved; these feel issues are open, not solved.

## Phase 2 handoff - 2026-11-06

Developer approval: **received (2026-11-06)** — see “Phase 2 manual feedback” entry below. Scene: contact_lab.tscn. Existing F1/F2/F5, C, Tab, I/K/J/L/U/O and R controls remain.

1. Identify the cyan player sword, horizontal grey blocking sword and translucent green probe on the left. Cycle C; report visibility/occlusion issues.
2. Without LMB, gently move into the grey blade. Use I/K to adjust depth. Desired and actual poses should separate under resistance. Report visible pass-throughs; sliding/rotating off an end is different from passing through the middle.
3. Maintain light pressure and move along the grey blade, then pull clear. Report sticking, jitter, unintended rotation and recovery. Use side view to establish which side of the blade you occupy.
4. Hold LMB and cross the green probe. It must not physically block. Watch accepted events and last contact kind (cut/thrust/flat/slow), region, speed and alignment. Report clear valid crossings that are missed.
5. Cross again while LMB stays held: no second event for that probe. Release/repress for a new trial. Cursor mode cancels the trial, requiring a fresh press afterward. RMB suppresses attack events and provides no automatic defense.
6. Try slow movements and broad-face/depth movement using I/K. Report whether slow/flat contacts are rejected. Yellow edge and pink face-normal axes help inspect orientation. No automatic wrist correction exists.
7. In F2, vary Opponent Friction, Blade Samples or Sweep Radius one at a time. Restore F5 while clear of fixtures. Report physical sliding separately from query misses/false positives; a larger radius is not necessarily more accurate.
8. Rate contact clarity, weight and desire to replay (1-5); describe broad-face hits/sluggishness. Supply camera, tuning values and log excerpts. **Phase 3 implementation authorized (2026-11-06)** per `docs/DECISIONS.md` / `docs/ROADMAP.md`; full ratings for item 8 remain optional.

ANTI_GOOFY status:
- Broad-face hit: partial diagnostic improvement (flat-score rejection and axes); orientation behavior unresolved.
- Unexplained slowness: open from Phase 1; no acceleration change.
- Aimed spot missed: partially diagnosed through sweeps; no intent steering.
- Sideways stab: assistance not yet testable; forward-tip scoring is implemented, not corrected aiming.
- Impossible arms / anatomical overreach / goofy walking: not yet testable; no character.
- Correct parry lost to wrist error: not yet testable; static contact is not parry assistance.
- Unforgiving/not-where-I-put-it control: open, mapping unchanged.
- Unintended actions: open, human evaluation needed.
- Freedom without absurd results: partial, bounded control/contact tests; not declared solved.
- Weight/momentum preservation: retained physical controller; subjective result pending.
- Angle/timing freedom: unchanged provisional mapping.
- Believable clashes: controlled blocking/sliding passes; subjective result pending.

## 2026-11-06 — Phase 2 manual feedback (developer)

- **Tester note (short):** Little else stood out; it feels like the swords can pass through each other near the **hand guard** region.
- **Explanation (not a bug for this lab build):** `SwordVisual` uses **one** `BoxShape3D` sized to blade + grip length; **crossguard and pommel meshes have no extra collision shapes**, so geometry there can visually overlap while the physics volume is only the central box. See `scripts/sword/sword_visual.gd` and `docs/ARCHITECTURE.md` (Phase 1 sword visual / collider notes).
- **Objective:** Separately validate **blade vs static opponent** contact and **green probe** hit detection per Phase 2 checklist; guard overlap is a known simplification until a dedicated hilt/collider layout is added (future work, not Phase 3 authorization by itself).
- **Ratings / full checklist:** Deferred; developer may fill after another focused pass or approve with this note.
- **Decision:** **Approved by developer (2026-11-06).** Proceed to Phase 3 implementation per `docs/ROADMAP.md` / `docs/DECISIONS.md`. Known limitation: guard/pommel visuals have no separate colliders in this lab build (`scripts/sword/sword_visual.gd`); may be revisited later.
