class_name LabDebugDraw
extends MeshInstance3D

const DESIRED: Color = Color(1.0, 0.5, 0.08)
const ACTUAL: Color = Color(0.05, 0.95, 1.0)
var lines: ImmediateMesh = ImmediateMesh.new()

func _ready() -> void:
	mesh = lines
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	material_override = mat
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func segment(a: Vector3, b: Vector3, color: Color) -> void:
	lines.surface_set_color(color)
	lines.surface_add_vertex(a)
	lines.surface_add_vertex(b)

func cross_at(point: Vector3, color: Color) -> void:
	for axis: Vector3 in [Vector3.RIGHT, Vector3.UP, Vector3.BACK]:
		segment(point - axis * 0.04, point + axis * 0.04, color)

func sword_outline(pose: Transform3D, tuning: SwordTuning, color: Color) -> void:
	var tip: float = tuning.grip_length * 0.5 + tuning.blade_length
	var width: float = tuning.blade_width * 0.7
	segment(pose * Vector3(-width, 0, 0), pose * Vector3(-width, tip, 0), color)
	segment(pose * Vector3(width, 0, 0), pose * Vector3(width, tip, 0), color)
	segment(pose * Vector3(-width, tip, 0), pose * Vector3(width, tip, 0), color)
	segment(pose * Vector3(-tuning.guard_width * 0.5, tuning.grip_length * 0.5, 0), pose * Vector3(tuning.guard_width * 0.5, tuning.grip_length * 0.5, 0), color)
	cross_at(pose.origin, color)

func redraw(body: SwordBody, planner: SwordMotionPlanner, pd: PhysicalSwordController, tuning: SwordTuning) -> void:
	lines.clear_surfaces()
	lines.surface_begin(Mesh.PRIMITIVE_LINES)
	sword_outline(planner.desired_pose, tuning, DESIRED)
	sword_outline(body.global_transform, tuning, ACTUAL)
	segment(body.global_position, planner.desired_pose.origin, Color.WHITE)
	segment(body.global_position, body.global_position + pd.applied_force * tuning.force_draw_scale, Color.GREEN)
	segment(body.global_position, body.global_position + pd.applied_torque * tuning.torque_draw_scale, Color.MAGENTA)
	cross_at(planner.target, Color.YELLOW)
	for point: Vector3 in body.contact_points:
		cross_at(point, Color.RED)
	# This is a lab target region, not a character's anatomical reach envelope.
	var low: Vector3 = Vector3(-tuning.horizontal_range, tuning.hilt_height - tuning.vertical_range, tuning.depth_min)
	var high: Vector3 = Vector3(tuning.horizontal_range, tuning.hilt_height + tuning.vertical_range, tuning.depth_max)
	for i: int in range(8):
		var a: Vector3 = Vector3(high.x if i & 1 else low.x, high.y if i & 2 else low.y, high.z if i & 4 else low.z)
		for bit: int in [1, 2, 4]:
			if i & bit:
				continue
			var j: int = i | bit
			var b: Vector3 = Vector3(high.x if j & 1 else low.x, high.y if j & 2 else low.y, high.z if j & 4 else low.z)
			segment(a, b, Color(0.35, 0.4, 0.45))
	lines.surface_end()
