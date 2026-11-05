extends SceneTree

var lab: ContactLab
var failures: Array[String] = []
var physical_trials: int = 0
var physical_passes: int = 0
var measured_slide: float = 0.0
var events: Array[BladeHit] = []
var missed_hits: int = 0
var duplicate_hits: int = 0
var false_positives: int = 0

func _initialize() -> void:
	call_deferred("run_checks")

func require(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)

func frames(count: int) -> void:
	for index: int in range(count):
		await physics_frame
		require(lab.sword.global_position.is_finite(), "Non-finite actual sword")
		require(lab.sword.linear_velocity.length() < 15.0, "Runaway contact speed")
		require(lab.controller.applied_force.length() <= lab.tuning.force_limit + 0.001, "Force cap exceeded")
		require(lab.controller.applied_torque.length() <= lab.tuning.torque_limit + 0.001, "Torque cap exceeded")

func on_hit(hit: BladeHit) -> void:
	events.append(hit)

func run_checks() -> void:
	lab = (load("res://scenes/test/contact_lab.tscn") as PackedScene).instantiate() as ContactLab
	root.add_child(lab)
	# Every numeric UI field must display the real value, without silent rounding.
	for info: Dictionary in lab.tuning.get_property_list():
		var key: StringName = StringName(info["name"])
		if lab.panel._editors.has(key):
			require(is_equal_approx(lab.panel._editors[key].value, float(lab.tuning.get(key))), "UI field mismatch: " + String(key))
		elif int(info["type"]) == TYPE_VECTOR3:
			var value: Vector3 = lab.tuning.get(key)
			for axis: int in range(3):
				var field_key: StringName = StringName(String(key) + str(axis))
				if lab.panel._editors.has(field_key):
					require(is_equal_approx(lab.panel._editors[field_key].value, value[axis]), "UI vector mismatch: " + String(field_key))
	lab.automation = true
	lab.input_reader.enabled = false
	lab.tuning.log_interval = 1000.0
	var home: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0.15, 1.0, 0.15))
	lab.automated_goal = Transform3D(Basis.IDENTITY, Vector3(-1.0, 0.8, 0.15))
	await frames(180)
	lab.automated_goal = home
	await frames(180)
	# Real Jolt collision: push through the opposing sword, slide, then withdraw.
	for trial: int in range(20):
		physical_trials += 1
		lab.automated_goal = Transform3D(Basis.IDENTITY, Vector3(0.15, 1.0, -0.48))
		var contact: bool = false
		for index: int in range(120):
			await frames(1)
			contact = contact or lab.sword.sword_contact
		var actual_pose: Transform3D = lab.sword.global_transform
		var blade_y: float = (lab.opponent.position.y - actual_pose.origin.y) / actual_pose.basis.y.y
		var blade_at_crossing: Vector3 = actual_pose * Vector3(0, blade_y, 0)
		require(blade_at_crossing.z > lab.opponent.position.z - 0.01, "Blade crossed opposing blade at intersection height")
		var start_x: float = lab.sword.global_position.x
		var contact_ticks: int = 0
		lab.automated_goal.origin.x = 0.6
		for index: int in range(120):
			await frames(1)
			if lab.sword.sword_contact:
				contact_ticks += 1
		var slide: float = absf(lab.sword.global_position.x - start_x)
		measured_slide = maxf(measured_slide, slide)
		require(slide > 0.25 and contact_ticks > 30, "No sustained sliding along sword")
		lab.automated_goal = home
		await frames(180)
		var settled: bool = lab.controller.position_error < lab.tuning.settled_position and rad_to_deg(lab.controller.angle_error) < lab.tuning.settled_angle_degrees
		if contact and settled:
			physical_passes += 1
		require(settled, "Failed to recover after sword contact")
	require(physical_passes == 20, "Not all physical contact trials passed")
	# Independent oracle: the known X segment crosses a fixed box centered at X=3.
	# Endpoints lie outside it; blade span covers Y=1, and Z=3 lies inside it.
	var probe: Area3D = Area3D.new()
	probe.collision_layer = CollisionLayers.HURTBOX
	probe.collision_mask = 0
	probe.position = Vector3(3, 1, 3)
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.08, 0.2, 0.2)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	probe.add_child(collision)
	lab.add_child(probe)
	await frames(3)
	var detector: BladeHitDetector = BladeHitDetector.new()
	detector.tuning = lab.contact_tuning
	detector.hit_detected.connect(on_hit)
	var space: PhysicsDirectSpaceState3D = lab.get_world_3d().direct_space_state
	var base: Vector3 = Vector3(0, 0.12, 0)
	var tip: Vector3 = Vector3(0, 1.07, 0)
	var excluded: Array[RID] = []
	var dt: float = 1.0 / 60.0
	for trial: int in range(100):
		var extent: float = 0.2 + float(trial % 5) * 0.1
		var from: Transform3D = Transform3D(Basis.IDENTITY, Vector3(3.0 - extent, 0.25, 3.0))
		var to: Transform3D = Transform3D(Basis.IDENTITY, Vector3(3.0 + extent, 0.25, 3.0))
		detector.reset_history()
		detector.step(space, from, base, tip, dt, false, excluded)
		var before: int = events.size()
		detector.step(space, to, base, tip, dt, true, excluded)
		detector.step(space, from, base, tip, dt, true, excluded)
		var produced: int = events.size() - before
		if produced == 0:
			missed_hits += 1
		if produced > 1:
			duplicate_hits += produced - 1
	# Nearby parallel paths have no overlap and must never emit hits.
	for trial: int in range(100):
		detector.reset_history()
		detector.step(space, Transform3D(Basis.IDENTITY, Vector3(2.5, 0.25, 3.4)), base, tip, dt, false, excluded)
		var before: int = events.size()
		detector.step(space, Transform3D(Basis.IDENTITY, Vector3(3.5, 0.25, 3.4)), base, tip, dt, true, excluded)
		false_positives += events.size() - before
	require(missed_hits <= 1 and duplicate_hits == 0 and false_positives == 0, "Translation sweep acceptance failed")
	# Flat, slow, tip-forward and tip-backward qualification independently.
	require(BladeHitDetector.qualify(Vector3(0, 0, 3), Basis.IDENTITY, 0.5, lab.contact_tuning).score == 0.0, "Flat contact counted as edge cut")
	require(BladeHitDetector.qualify(Vector3(0.01, 0, 0), Basis.IDENTITY, 0.5, lab.contact_tuning).score == 0.0, "Slow contact generated score")
	require(BladeHitDetector.qualify(Vector3(0, 3, 0), Basis.IDENTITY, 1.0, lab.contact_tuning).kind == "thrust", "Tip-forward thrust rejected")
	require(BladeHitDetector.qualify(Vector3(0, -3, 0), Basis.IDENTITY, 1.0, lab.contact_tuning).score == 0.0, "Tip withdrawal counted as thrust")
	var forte: float = BladeHitDetector.qualify(Vector3(3, 0, 0), Basis.IDENTITY, 0.1, lab.contact_tuning).score
	var foible: float = BladeHitDetector.qualify(Vector3(3, 0, 0), Basis.IDENTITY, 0.6, lab.contact_tuning).score
	require(foible > forte, "Blade region weighting ignored")
	# Curved rotational path: target sits on the arc, away from its endpoint chord.
	probe.position = Vector3(3.7071, 0.7071, 3)
	shape.size = Vector3(0.08, 0.08, 0.08)
	await frames(3)
	detector.reset_history()
	detector.step(space, Transform3D(Basis.IDENTITY, Vector3(3, 0, 3)), base, tip, dt, false, excluded)
	var rotation_before: int = events.size()
	detector.step(space, Transform3D(Basis(Vector3.BACK, -PI * 0.5), Vector3(3, 0, 3)), base, tip, dt, true, excluded)
	require(events.size() == rotation_before + 1, "Rotational arc sweep missed target")
	# Self/owner exclusion must apply to the hurtbox RID, not only rigid bodies.
	detector.reset_history()
	excluded.append(probe.get_rid())
	detector.step(space, Transform3D(Basis.IDENTITY, Vector3(3, 0, 3)), base, tip, dt, false, excluded)
	var exclusion_before: int = events.size()
	detector.step(space, Transform3D(Basis(Vector3.BACK, -PI * 0.5), Vector3(3, 0, 3)), base, tip, dt, true, excluded)
	require(events.size() == exclusion_before, "Excluded owner hurtbox generated hit")
	print("PHASE2_TEST_RESULT ", JSON.stringify({"failures": failures, "physical_trials": physical_trials, "physical_passes": physical_passes, "max_slide_m": measured_slide, "damage_trials": 100, "missed_hits": missed_hits, "duplicate_hits": duplicate_hits, "false_positive_trials": 100, "false_positives": false_positives, "rotation_hit": events.size() > rotation_before}))
	lab.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
