# Sword asset specification — Phase 1 placeholder

Origin: primary grip center. Local +Y runs along the blade toward the tip; +X is the true-edge outward direction, -X the opposite edge; +Z is the broad face normal. This defines the previously pending axes. The visual is a box blade, grip, crossguard and pommel, not a final asset or tapered collision mesh.

Defaults: blade 0.95 m; grip 0.24 m; overall geometry about 1.215 m including pommel. Mass 1.3 kg. COM local Y=0.32 m; transverse inertia 0.16 kg m^2, axial inertia 0.004 kg m^2. These are editable starting approximations, not a measured distribution or automatic inertia calculation. Changing mesh dimensions does not automatically retune inertia.

Marker3D children: GripMain at origin, GripFront near the guard, Pommel at rear, Crossguard/BladeBase at grip_length/2, BladeMid halfway along the blade, Tip at grip_length/2 + blade_length. Marker coordinates update with geometry tuning.

A separate single BoxShape3D spans grip and blade. The visible guard and pommel protrusions do not block objects in Phase 1. No swept damage sample system exists yet. Future assets must preserve these axes and marker names or explicitly document a conversion.
