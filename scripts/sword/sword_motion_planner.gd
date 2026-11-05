class_name SwordMotionPlanner
extends RefCounted

var tuning: SwordTuning
var depth_strategy: DepthStrategy = TargetDepthStrategy.new()
var desired_pose: Transform3D = Transform3D.IDENTITY
var desired_velocity: Vector3 = Vector3.ZERO
var desired_angular_velocity: Vector3 = Vector3.ZERO
var target: Vector3
var _goal_position: Vector3
var _goal_basis: Basis

func initialize(settings: SwordTuning) -> void:
	tuning = settings
	target = tuning.target_start
	_goal_position = Vector3(0.0, tuning.hilt_height, depth_strategy.desired_depth(target, 0.0, tuning))
	_goal_basis = Basis(Vector3.RIGHT, deg_to_rad(tuning.rest_pitch_degrees))
	desired_pose = Transform3D(_goal_basis, _goal_position)

func recenter() -> void:
	target = tuning.target_start
	_goal_position = Vector3(0.0, tuning.hilt_height, depth_strategy.desired_depth(target, 0.0, tuning))
	_goal_basis = Basis(Vector3.RIGHT, deg_to_rad(tuning.rest_pitch_degrees))

func step(delta: float, motion: Vector2, view: Basis, target_direction: Vector3) -> void:
	target += target_direction * tuning.target_move_speed * delta
	target = target.clamp(tuning.target_min.min(tuning.target_max), tuning.target_min.max(tuning.target_max))
	# Convert screen motion to world space, then constrain the lab's hilt region.
	var screen_right: Vector3 = Vector3(view.x.x, view.x.y, 0.0).normalized()
	var screen_up: Vector3 = Vector3(view.y.x, view.y.y, 0.0).normalized()
	_goal_position += (screen_right * motion.x - screen_up * motion.y) * tuning.mouse_sensitivity
	_goal_position.x = clampf(_goal_position.x, -tuning.horizontal_range, tuning.horizontal_range)
	_goal_position.y = clampf(_goal_position.y, tuning.hilt_height - tuning.vertical_range, tuning.hilt_height + tuning.vertical_range)
	_goal_position.z = depth_strategy.desired_depth(target, _goal_position.z, tuning)
	var tilt: float = deg_to_rad(tuning.mouse_tilt_degrees)
	var roll: float = -_goal_position.x / tuning.horizontal_range * tilt
	var pitch: float = deg_to_rad(tuning.rest_pitch_degrees) + (_goal_position.y - tuning.hilt_height) / tuning.vertical_range * tilt
	_goal_basis = Basis(Vector3.FORWARD, roll) * Basis(Vector3.RIGHT, pitch)
	advance_to(delta, Transform3D(_goal_basis, _goal_position))

func advance_to(delta: float, goal: Transform3D) -> void:
	var previous: Transform3D = desired_pose
	desired_pose.origin = desired_pose.origin.move_toward(goal.origin, tuning.desired_speed_limit * delta)
	var from: Quaternion = desired_pose.basis.get_rotation_quaternion()
	var to: Quaternion = goal.basis.get_rotation_quaternion()
	var distance: float = from.angle_to(to)
	var weight: float = minf(1.0, tuning.desired_angular_speed * delta / maxf(distance, 0.000001))
	desired_pose.basis = Basis(from.slerp(to, weight))
	desired_velocity = (desired_pose.origin - previous.origin) / delta
	var rotation_delta: Quaternion = desired_pose.basis.get_rotation_quaternion() * previous.basis.get_rotation_quaternion().inverse()
	if rotation_delta.w < 0.0:
		rotation_delta = -rotation_delta
	desired_angular_velocity = Vector3(rotation_delta.x, rotation_delta.y, rotation_delta.z) * 2.0 / delta
