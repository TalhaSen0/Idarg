class_name BladeHitDetector
extends RefCounted

signal hit_detected(hit: BladeHit)

var tuning: ContactTuning
var automatic_swing_start: bool = true
var swing_id: int = 0
var hits: int = 0
var candidate_frames: int = 0
var duplicate_candidates: int = 0
var subdivision_limit_frames: int = 0
var query_count: int = 0
var last_candidate: BladeHit
var last_hit: BladeHit
var sweep_lines: PackedVector3Array = PackedVector3Array()
var sample_points: PackedVector3Array = PackedVector3Array()
var _previous: Transform3D
var _has_previous: bool = false
var _attacking: bool = false
var _hit_targets: Dictionary[int, bool] = {}

func reset_history() -> void:
	_has_previous = false
	sweep_lines.clear()
	sample_points.clear()

func begin_swing() -> void:
	swing_id += 1
	_hit_targets.clear()

static func qualify(velocity: Vector3, orientation: Basis, fraction: float, settings: ContactTuning) -> BladeHit:
	var hit: BladeHit = BladeHit.new()
	hit.speed = velocity.length()
	hit.blade_fraction = fraction
	hit.region = "tip" if fraction >= settings.tip_start_fraction else ("forte" if fraction < settings.forte_end_fraction else "foible")
	if hit.speed < settings.minimum_hit_speed:
		hit.kind = "slow"
		return hit
	var direction: Vector3 = velocity.normalized()
	var edge: float = absf(direction.dot(orientation.x.normalized()))
	var tip: float = maxf(0.0, direction.dot(orientation.y.normalized())) if hit.region == "tip" else 0.0
	if tip >= settings.minimum_tip_alignment and tip > edge:
		hit.kind = "thrust"
		hit.alignment = tip
	elif edge >= settings.minimum_edge_alignment:
		hit.kind = "cut"
		hit.alignment = edge
	else:
		hit.kind = "flat"
		hit.alignment = maxf(edge, tip)
		return hit
	var weight: float = settings.tip_weight if hit.region == "tip" else (settings.forte_weight if hit.region == "forte" else settings.foible_weight)
	hit.score = hit.speed * hit.speed * hit.alignment * weight * settings.score_scale
	return hit

func step(space: PhysicsDirectSpaceState3D, actual: Transform3D, blade_base: Vector3, blade_tip: Vector3, delta: float, attacking: bool, excluded: Array[RID]) -> void:
	if automatic_swing_start and attacking and not _attacking:
		begin_swing()
	_attacking = attacking
	sweep_lines.clear()
	sample_points.clear()
	query_count = 0
	if not _has_previous:
		_previous = actual
		_has_previous = true
		return
	var angle: float = _previous.basis.get_rotation_quaternion().angle_to(actual.basis.get_rotation_quaternion())
	var requested: int = maxi(1, ceili(angle / deg_to_rad(tuning.rotation_step_degrees)))
	var steps: int = mini(requested, tuning.max_rotation_steps)
	if requested > steps:
		subdivision_limit_frames += 1
	var candidates: Dictionary[int, BladeHit] = {}
	for substep: int in range(steps):
		var from: Transform3D = _previous.interpolate_with(actual, float(substep) / float(steps))
		var to: Transform3D = _previous.interpolate_with(actual, float(substep + 1) / float(steps))
		var middle: Basis = from.basis.slerp(to.basis, 0.5)
		for sample: int in range(tuning.blade_samples):
			var fraction: float = float(sample) / float(tuning.blade_samples - 1)
			var local: Vector3 = blade_base.lerp(blade_tip, fraction)
			var start: Vector3 = from * local
			var end: Vector3 = to * local
			sweep_lines.append(start)
			sweep_lines.append(end)
			if substep == steps - 1:
				sample_points.append(end)
			_query_segment(space, start, end, middle, fraction, delta / float(steps), excluded, candidates)
	_previous = actual
	if not candidates.is_empty():
		candidate_frames += 1
	for target_id: int in candidates:
		var hit: BladeHit = candidates[target_id]
		last_candidate = hit
		if not attacking or hit.score <= 0.0:
			continue
		if _hit_targets.has(target_id):
			duplicate_candidates += 1
			continue
		_hit_targets[target_id] = true
		hit.swing_id = swing_id
		hits += 1
		last_hit = hit
		hit_detected.emit(hit)

func _query_segment(space: PhysicsDirectSpaceState3D, start: Vector3, end: Vector3, orientation: Basis, fraction: float, delta: float, excluded: Array[RID], candidates: Dictionary[int, BladeHit]) -> void:
	var motion: Vector3 = end - start
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = tuning.sweep_radius
	capsule.height = motion.length() + 2.0 * tuning.sweep_radius
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform = Transform3D(Basis(Quaternion(Vector3.UP, motion.normalized())) if motion.length_squared() > 0.00000001 else Basis.IDENTITY, (start + end) * 0.5)
	query.collision_mask = CollisionLayers.DAMAGE_QUERY_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = excluded
	query_count += 1
	var overlaps: Array[Dictionary] = space.intersect_shape(query, tuning.query_max_results)
	for overlap: Dictionary in overlaps:
		var target_id: int = int(overlap["collider_id"])
		var hit: BladeHit = qualify(motion / delta, orientation, fraction, tuning)
		hit.target_id = target_id
		# Restrict rest-info to this candidate, not another overlapping hurtbox.
		var others: Array[RID] = excluded.duplicate()
		for other: Dictionary in overlaps:
			if int(other["collider_id"]) != target_id:
				others.append(other["rid"])
		query.exclude = others
		var rest: Dictionary = space.get_rest_info(query)
		hit.position = rest.get("point", end)
		if not candidates.has(target_id) or hit.score > candidates[target_id].score:
			candidates[target_id] = hit
