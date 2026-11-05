# Phase gates

Work on one phase at a time. Every phase ends with a runnable scene, runtime tuning, objective evidence where available, a manual checklist, ANTI_GOOFY status, and explicit developer approval before the next phase. Reaching a gate does not automatically authorize the next phase.

| Phase | Deliverable and gate |
|---|---|
| 0 | Folder/docs scaffolding, working diagnostic scene, live debug settings, logging, Git baseline. User confirms run/toggle/edit/reset behavior. |
| 1 | Sword Lab, no character. A: free tracking with no runaway. B: stable recovery after a hard obstacle. Resolve camera/input routing and depth-target behavior first. |
| 2 | Contact Lab. C: swords block and slide; swept damage query is distinct from physical contact. |
| 3 | Kinematic body, actual-grip ArmIK, reach envelope, torso twist. No impossible poses; no physical legs. |
| 4 | Separate attack/parry assistance controls. Verify RMB/direction/timing gate, in-gate contact guarantee, zero out-of-gate/no-RMB help, and physical-limit compatibility. |
| 5 | Hit reactions, stagger, blocked-sword pushback, damage/death. |
| 6 | AI using shared intents and a basic 1v1 loop. |
| 7 | Future work only: polish/audio/camera refinement; evaluate physical body goal. Not currently authorized. |

## Proposed measurable Phase 1–2 starting gates

Phase 1: 100 fast reversals without runaway; 20 hard-obstacle contacts without sustained oscillation or lock-up. Record position/angular tracking error, overshoot and recovery time with tuning snapshot and input scenario. Physical resistance may intentionally create error; do not optimize away weight. Exact speed, recovery-band and settling-time limits require test calibration, not invented success claims.

Phase 2: at most 1 missed damage detection per 100 known contact opportunities and zero duplicate damage events. Record false positives separately. Establish opportunities from controlled scripted trajectories plus debug evidence, not from the detector being tested. Test blocking and sliding repeatedly at documented angles/speeds.

Manual gate: slow guidance, abrupt reversal, withdrawal from an obstacle, and sliding along a second blade. Rate control clarity, weight, and desire to replay 1–5; proposed target >=4 each plus explicit developer approval. Also count/report actions that felt "not what I intended". These provisional numbers may be revised explicitly after baseline playtesting.

## Stop / redirect criteria

- Any runaway, persistent lock-up, unstable contact, or impossible pose blocks its applicable gate.
- If tuning only trades uncontrollable lag for weightlessness, remain in the phase and compare control/depth alternatives with the developer; do not add content to hide it.
- If controlled contact tests cannot reliably prevent tunneling/missed hits, investigate physics tick, sweep coverage and speed envelope before character work.
- If in-gate parry guarantees require teleportation or unbounded forces, stop Phase 4 and present a documented choice about gate feasibility or design constraints. Do not silently weaken the approved guarantee.
- If the developer still does not enjoy the lab after documented tuning comparisons, request a redirect or stop decision; technical metrics do not overrule feel.

## Current gate state

Phase 0 approved by developer (F1/F2/F5 confirmed). Phase 1 implementation and automated checks complete; manual feel approval pending. Phase 2 remains unauthorized. The initial camera/input and reference-depth decisions are resolved in DECISIONS.md; the conditional parry feasibility question remains a Phase 4 issue.

## Phase 2 gate state - 2026-11-06

Phase 1 was subsequently approved for progression with open feel feedback. Phase 2 implementation and controlled checks are complete; developer playtest is pending. Phase 3 is NOT authorized. The broad-face/sluggishness observations remain open, and no acceleration or assistance has been added.
