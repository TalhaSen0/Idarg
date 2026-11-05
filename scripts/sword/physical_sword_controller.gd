class_name PhysicalSwordController
extends RefCounted

var applied_force: Vector3 = Vector3.ZERO
var applied_torque: Vector3 = Vector3.ZERO
var position_error: float = 0.0
var angle_error: float = 0.0

static func rotation_error(desired: Basis, actual: Basis) -> Vector3:
	var error: Quaternion = (desired.get_rotation_quaternion() * actual.get_rotation_quaternion().inverse()).normalized()
	if error.w < 0.0:
		error = -error
	var imaginary: Vector3 = Vector3(error.x, error.y, error.z)
	if imaginary.length_squared() < 0.00000001:
		return imaginary * 2.0
	return imaginary.normalized() * (2.0 * atan2(imaginary.length(), error.w))

func step(body: RigidBody3D, desired: Transform3D, settings: SwordTuning, delta: float) -> void:
	var local_com: Vector3 = Vector3(0.0, settings.center_of_mass_y, 0.0)
	var error: Vector3 = (desired * local_com) - (body.global_transform * local_com)
	position_error = body.global_position.distance_to(desired.origin)
	var angular_error: Vector3 = rotation_error(desired.basis, body.global_basis.orthonormalized())
	angle_error = angular_error.length()
	# Implicit-PD gain scaling prevents high gains from exploding at a fixed step.
	# Damping uses actual velocity; no velocity is assigned or clamped after contact.
	var position_denominator: float = 1.0 + settings.position_damping * delta + settings.position_gain * delta * delta
	var acceleration: Vector3 = (settings.position_gain * error - (settings.position_damping + settings.position_gain * delta) * body.linear_velocity) / position_denominator
	var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	applied_force = (settings.mass_kg * (acceleration + Vector3.UP * gravity)).limit_length(settings.force_limit)
	var rotation_denominator: float = 1.0 + settings.rotation_damping * delta + settings.rotation_gain * delta * delta
	var angular_acceleration: Vector3 = (settings.rotation_gain * angular_error - (settings.rotation_damping + settings.rotation_gain * delta) * body.angular_velocity) / rotation_denominator
	var local_acceleration: Vector3 = body.global_basis.transposed() * angular_acceleration
	applied_torque = (body.global_basis * (body.inertia * local_acceleration)).limit_length(settings.torque_limit)
	body.apply_central_force(applied_force)
	body.apply_torque(applied_torque)
