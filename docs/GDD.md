# Game design draft

## Experiment

Prove that an intent-driven, physics-assisted two-handed longsword can feel controllable, weighty, and believable. Preserve angle/timing freedom and physical clashes while reducing unintended flat hits, sideways thrusts, unnatural arms, and arbitrary sluggishness. VISION.md takes precedence when source documents conflict; report conflicts before deciding.

## Approved controls and view

Third-person over-the-shoulder camera; keyboard and mouse. LMB signals attack intent, RMB signals defend intent, neither signals neutral/guard. Mouse motion drives a virtual sword target. Target-based automatic depth is a replaceable module; scroll and motion-speed strategies remain alternatives, not implemented features. Phase 1 uses fixed preset views, cursor capture for sword input, and one movable debug reference; there is no acquisition/switching system.

## Physical execution

Desired pose/velocity remains separate from actual physical pose/velocity. A force/torque-limited PD controller drives the sword; no teleportation. Hands follow actual grip markers. Shoulder-centered reach limits and later torso motion keep the target anatomically feasible. Body and legs are initially kinematic.

Attack and parry assistance have separate strengths; 0 means manual. Attack assistance aligns the edge/wrist and may apply bounded corrections. Parry assistance ensures contact only while RMB is held AND movement direction plus timing pass the adjustable gate. No assistance outside that gate or without RMB. This exception does not grant automatic attack contact or unconditional defense. The guarantee's compatibility with physical limits is a required Phase 4 test, not a solved result.

## Scope

One longsword, 1v1, no half-swording. First build sword-only labs; character, assists, reactions, and AI come later behind individual approvals. AI eventually emits the same intent data as the player. Physical body is a long-term goal. Menus, content, sound, and polish are outside the current experiment scope.

## Acceptance

Use ROADMAP.md for phase gates and PLAYTEST_LOG.md for evidence. Every ANTI_GOOFY.md item receives a status each phase. Technical stability alone cannot establish fun. No character means anatomical and walking requirements are not yet testable; no assist means assisted intent requirements are not yet testable.

## Phase 1 lab implementation

The character-free lab uses a fixed view with C-cycled rear, side and shoulder-like angles. Mouse displacement translates the hilt in a bounded region and maps that displacement to bounded pitch/roll. This is a provisional control mapping for feel testing, not swing classification or wrist assistance. No independent manual yaw/roll binding, stab recognition, or edge alignment exists yet. A visible movable reference drives automatic depth through a replaceable strategy; lateral/vertical reference motion does not aim or magnetize the sword.

Tab releases/captures the cursor. F2 opens a translucent corner panel and releases the cursor; physics continues tracking the held target. Closing the panel resumes control. R recenters only the desired goal and depth reference; the physical sword returns through the controller. F1 hides debug graphics/metrics; it does not hide the physical sword, obstacle or target marker. F5 restores tuning defaults.

## Phase 2 lab

A fixed horizontal grey sword tests physical blocking/sliding. A separate translucent green probe tests detection without physical resistance. Previous mouse/controller behavior remains unchanged.

Hold LMB and pass through the green probe to attempt a hit; release/repress for a new trial. Valid cuts require actual speed and edge alignment. Thrusts must lead with the tip in the blade-forward direction. Flat/slow overlaps are visible but do not score. RMB inhibits attack events. No swing recognition, injury, enemy behavior or automatic wrist correction is implemented.
