class_name SwordBody
extends RigidBody3D

var contact_points: PackedVector3Array = PackedVector3Array()
var obstacle_contact: bool = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Read-only contact snapshot: control forces are applied in _physics_process.
	contact_points.clear()
	obstacle_contact = false
	for index: int in range(state.get_contact_count()):
		contact_points.append(state.get_contact_collider_position(index))
		var collider: Object = state.get_contact_collider_object(index)
		if collider is Node and (collider as Node).name == &"HardObstacle":
			obstacle_contact = true
