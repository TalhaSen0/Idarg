# Sword asset specification (draft)

No sword asset is created in Phase 0. Origin must be the primary/rear grip center. GripMain, GripFront, Pommel, Crossguard, BladeBase, BladeMid and Tip are required Marker3D children when a sword is introduced. Derive damage samples from blade markers; use a separate simple collision shape instead of visual-mesh collision.

Physical starting range: approximately 1.2–1.4 kg and 1.1–1.3 m for the longsword. Exact values, mass distribution and inertia belong in runtime-editable tuning Resources.

Blade and edge axes are deliberately pending before the first asset/Phase 1 implementation. Document one explicit coordinate convention here before creating a model or consuming its transforms; do not infer axes from appearance.
