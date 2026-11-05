class_name ContactDebugDraw
extends LabDebugDraw

func draw_detector(detector: BladeHitDetector, sword: SwordBody, tuning: ContactTuning) -> void:
	lines.clear_surfaces()
	lines.surface_begin(Mesh.PRIMITIVE_LINES)
	for index: int in range(0, detector.sweep_lines.size(), 2):
		segment(detector.sweep_lines[index], detector.sweep_lines[index + 1], Color(0.8, 0.5, 1.0))
	for point: Vector3 in detector.sample_points:
		cross_at(point, Color(0.6, 1.0, 0.2))
	if detector.last_candidate != null:
		cross_at(detector.last_candidate.position, Color.RED)
	# Explicit blade edge/face axes make flat-face contact easy to diagnose.
	var middle: Vector3 = sword.global_transform * Vector3(0, tuning.grip_length * 0.5 + tuning.blade_length * 0.5, 0)
	segment(middle, middle + sword.global_basis.x * 0.25, Color.YELLOW)
	segment(middle, middle + sword.global_basis.z * 0.25, Color(0.9, 0.2, 0.8))
	lines.surface_end()
