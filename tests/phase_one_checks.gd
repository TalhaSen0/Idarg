extends SceneTree

var lab: SwordLab
var failures: Array[String] = []
var peak_speed: float = 0.0
var peak_error: float = 0.0
var peak_overshoot: float = 0.0
var peak_recovery: float = 0.0
var observed_contacts: int = 0

func _initialize() -> void:
	call_deferred("run_checks")

func require(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)

func step_frames(count: int) -> void:
	for index: int in range(count):
		await physics_frame
		if not is_instance_valid(lab):
			return
		peak_speed = maxf(peak_speed, lab.sword.linear_velocity.length())
		peak_error = maxf(peak_error, lab.controller.position_error)
		require(lab.sword.global_position.is_finite(), "Non-finite actual pose")
		require(lab.sword.linear_velocity.length() < 15.0, "Runaway linear speed")
		require(lab.sword.angular_velocity.length() < 30.0, "Runaway angular speed")
		require(lab.sword.global_position.length() < 8.0, "Sword escaped lab")
		require(lab.controller.applied_force.length() <= lab.tuning.force_limit + 0.001, "Force cap exceeded")
		require(lab.controller.applied_torque.length() <= lab.tuning.torque_limit + 0.001, "Torque cap exceeded")

func run_checks() -> void:
	var scene: PackedScene = load("res://scenes/test/sword_lab.tscn") as PackedScene
	lab = scene.instantiate() as SwordLab
	root.add_child(lab)
	lab.automation = true
	lab.input_reader.enabled = false
	lab.tuning.log_interval = 10.0
	var basis: Basis = Basis(Vector3.RIGHT, deg_to_rad(lab.tuning.rest_pitch_degrees))
	var home: Transform3D = Transform3D(basis, Vector3(-0.55, 1.25, -0.05))
	lab.automated_goal = home
	await step_frames(180)
	# Shortest-path quaternion and replaceable depth strategy checks.
	require(PhysicalSwordController.rotation_error(Basis(Vector3.UP, deg_to_rad(-179.0)), Basis(Vector3.UP, deg_to_rad(179.0))).length() < deg_to_rad(3.0), "Quaternion crossed long arc")
	var strategy: DepthStrategy = TargetDepthStrategy.new()
	require(is_equal_approx(strategy.desired_depth(Vector3(0, 1, -99), 0, lab.tuning), lab.tuning.depth_min), "Depth lower clamp")
	require(is_equal_approx(strategy.desired_depth(Vector3(0, 1, 99), 0, lab.tuning), lab.tuning.depth_max), "Depth upper clamp")
	# Exercise raw mouse spikes through the planner independently of the physics test.
	var probe: SwordMotionPlanner = SwordMotionPlanner.new()
	probe.initialize(lab.tuning)
	for index: int in range(100):
		probe.step(1.0 / 60.0, Vector2(100000.0 if index % 2 else -100000.0, 100000.0), Basis.IDENTITY, Vector3.ZERO)
		require(probe.desired_velocity.length() <= lab.tuning.desired_speed_limit + 0.001, "Desired speed limit exceeded")
		require(probe.desired_pose.origin.is_finite(), "Non-finite desired pose")
	# Test A: one hundred rapid target reversals including angular changes.
	for index: int in range(100):
		var side: float = 1.0 if index % 2 else -1.0
		lab.automated_goal = Transform3D(Basis(Vector3.BACK, side * 0.3) * basis, Vector3(-0.55 + side * 0.3, 1.25, -0.05))
		await step_frames(15)
	lab.automated_goal = home
	await step_frames(180)
	require(lab.controller.position_error < lab.tuning.settled_position, "Free recovery position did not settle")
	require(rad_to_deg(lab.controller.angle_error) < lab.tuning.settled_angle_degrees, "Free recovery angle did not settle")
	# Step response: displacement beyond the requested endpoint is positional overshoot.
	var step_start: Vector3 = home.origin
	var step_end: Vector3 = Vector3(-0.15, 1.25, -0.05)
	lab.automated_goal = Transform3D(basis, step_end)
	for index: int in range(180):
		await step_frames(1)
		peak_overshoot = maxf(peak_overshoot, maxf(0.0, (lab.sword.global_position - step_end).dot((step_end - step_start).normalized())))
	# Test B: twenty confirmed obstacle contacts, each followed by withdrawal.
	for trial: int in range(20):
		lab.automated_goal = Transform3D(basis, Vector3(0.9, 1.25, -0.05))
		var hit: bool = false
		for index: int in range(120):
			await step_frames(1)
			hit = hit or lab.sword.obstacle_contact
		if hit:
			observed_contacts += 1
		lab.automated_goal = home
		var recovery: float = -1.0
		var stable_frames: int = 0
		for index: int in range(240):
			await step_frames(1)
			var settled: bool = not lab.sword.obstacle_contact and lab.controller.position_error < lab.tuning.settled_position and rad_to_deg(lab.controller.angle_error) < lab.tuning.settled_angle_degrees and lab.sword.linear_velocity.length() < lab.tuning.settled_speed
			stable_frames = stable_frames + 1 if settled else 0
			if stable_frames >= 18 and recovery < 0.0:
				recovery = float(index + 1) / 60.0
		require(recovery >= 0.0, "Obstacle recovery did not settle within 4 seconds")
		peak_recovery = maxf(peak_recovery, recovery)
	require(observed_contacts == 20, "Not all twenty obstacle trials made physical contact")
	print("PHASE1_TEST_RESULT ", JSON.stringify({"failures": failures, "reversals": 100, "contact_trials": 20, "confirmed_contacts": observed_contacts, "peak_speed_m_s": peak_speed, "peak_error_m": peak_error, "step_overshoot_m": peak_overshoot, "worst_withdrawal_settle_seconds": peak_recovery}))
	lab.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
