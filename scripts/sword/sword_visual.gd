class_name SwordVisual
extends RefCounted

static func material(color: Color) -> StandardMaterial3D:
	var result: StandardMaterial3D = StandardMaterial3D.new()
	result.albedo_color = color
	return result

static func box(parent: Node3D, size: Vector3, offset: Vector3, color: Color) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material(color)
	instance.position = offset
	parent.add_child(instance)
	return instance

static func build(body: SwordBody, tuning: SwordTuning) -> void:
	var guard_y: float = tuning.grip_length * 0.5
	box(body, Vector3(tuning.blade_width, tuning.blade_length, tuning.blade_thickness), Vector3(0.0, guard_y + tuning.blade_length * 0.5, 0.0), Color(0.65, 0.85, 0.9))
	box(body, Vector3(0.035, tuning.grip_length, 0.035), Vector3.ZERO, Color(0.16, 0.09, 0.05))
	box(body, Vector3(tuning.guard_width, 0.03, 0.04), Vector3(0.0, guard_y, 0.0), Color(0.6, 0.47, 0.22))
	box(body, Vector3(0.06, 0.05, 0.06), Vector3(0.0, -guard_y, 0.0), Color(0.6, 0.47, 0.22))
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(tuning.blade_width, tuning.blade_length + tuning.grip_length, tuning.blade_thickness)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = tuning.blade_length * 0.5
	body.add_child(collision)
	var markers: Dictionary[String, float] = {
		"GripMain": 0.0, "GripFront": guard_y * 0.65, "Pommel": -guard_y,
		"Crossguard": guard_y, "BladeBase": guard_y,
		"BladeMid": guard_y + tuning.blade_length * 0.5, "Tip": guard_y + tuning.blade_length}
	for marker_name: String in markers:
		var marker: Marker3D = Marker3D.new()
		marker.name = marker_name
		marker.position.y = markers[marker_name]
		body.add_child(marker)
