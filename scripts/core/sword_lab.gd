class_name SwordLab
extends Node3D

const DEFAULT_TUNING: SwordTuning = preload("res://resources/tuning/sword_tuning.tres")

@export var tuning_resource: SwordTuning = DEFAULT_TUNING
@export var tuning_first_group: String = ""

var tuning: SwordTuning
var input_reader: LabInput
var planner: SwordMotionPlanner = SwordMotionPlanner.new()
var controller: PhysicalSwordController = PhysicalSwordController.new()
var metrics: LabMetrics = LabMetrics.new()
var sword: SwordBody
var camera: Camera3D
var obstacle: StaticBody3D
var target_mesh: MeshInstance3D
var debug_draw: LabDebugDraw
var panel: LabPanel
var overlay: Label
var help: Label
var camera_index: int = 0
var automation: bool = false
var automated_goal: Transform3D
var _pending_settings: bool = false
var _rebuild_sword: bool = false
var _display_elapsed: float = 0.0

func _ready() -> void:
	tuning = tuning_resource.duplicate() as SwordTuning
	planner.initialize(tuning)
	automated_goal = planner.desired_pose
	_build_world()
	input_reader = LabInput.new()
	add_child(input_reader)
	sword = SwordBody.new()
	sword.name = "PhysicalSword"
	sword.transform = planner.desired_pose
	sword.collision_layer = CollisionLayers.PLAYER_SWORD
	sword.collision_mask = CollisionLayers.PLAYER_SWORD_MASK
	sword.continuous_cd = true
	sword.contact_monitor = true
	sword.max_contacts_reported = 16
	sword.can_sleep = false
	sword.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	sword.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	sword.linear_damp = 0.0
	sword.angular_damp = 0.0
	sword.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	add_child(sword)
	SwordVisual.build(sword, tuning)
	_apply_body_settings()
	debug_draw = LabDebugDraw.new()
	add_child(debug_draw)
	_build_ui()
	set_camera(0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("SWORD_LAB_START ", Engine.get_version_info()["string"], " tuning=", tuning_resource.resource_path)
	get_viewport().size_changed.connect(_layout_panel)
	_layout_panel()

func _build_world() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.055, 0.075, 0.1)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.65, 0.72, 0.82)
	environment.environment.ambient_light_energy = 0.65
	add_child(environment)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, -25, 0)
	light.shadow_enabled = true
	add_child(light)
	make_obstacle("Floor", Vector3(8, 0.2, 8), Vector3(0, -0.1, 0), Color(0.18, 0.22, 0.26))
	obstacle = make_obstacle("HardObstacle", tuning.obstacle_size, tuning.obstacle_position, Color(0.48, 0.24, 0.15))
	# Floor guides are visual only, not collision surfaces.
	for index: int in range(-4, 5):
		SwordVisual.box(self, Vector3(8, 0.003, 0.008), Vector3(0, 0.002, index), Color(0.28, 0.33, 0.37))
		SwordVisual.box(self, Vector3(0.008, 0.003, 8), Vector3(index, 0.002, 0), Color(0.28, 0.33, 0.37))
	target_mesh = SwordVisual.box(self, Vector3(0.08, 0.08, 0.08), planner.target, Color(1, 0.8, 0.05))
	camera = Camera3D.new()
	camera.current = true
	add_child(camera)

func make_obstacle(node_name: String, size: Vector3, location: Vector3, color: Color) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = location
	body.collision_layer = CollisionLayers.WORLD
	body.collision_mask = CollisionLayers.WORLD_MASK
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "Collision"
	collision.shape = shape
	body.add_child(collision)
	SwordVisual.box(body, size, Vector3.ZERO, color).name = "Visual"
	add_child(body)
	return body

func _build_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	help = Label.new()
	help.position = Vector2(16, 12)
	help.text = "SWORD LAB | Mouse: sword | Tab: cursor/control | C: view | R: recenter target\nF1: debug | F2: tuning | F5: defaults | I/K: target depth | J/L: left/right | U/O: up/down\nORANGE desired | CYAN actual | GREEN force | MAGENTA torque | RED contact | YELLOW depth reference"
	help.add_theme_font_size_override("font_size", 15)
	help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(help)
	overlay = Label.new()
	overlay.position = Vector2(16, 90)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(overlay)
	panel = LabPanel.new()
	panel.tuning = tuning
	panel.defaults_path = tuning_resource.resource_path
	panel.first_group = tuning_first_group
	panel.setting_changed.connect(_on_setting_changed)
	panel.close_requested.connect(_close_panel)
	canvas.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_layout_panel()
	panel.hide()

func _layout_panel() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	panel.offset_left = -minf(tuning.panel_width, viewport_size.x * 0.45) - 12.0
	panel.offset_right = -12.0
	panel.offset_top = viewport_size.y * (1.0 - tuning.panel_height_fraction) - 12.0
	panel.offset_bottom = viewport_size.y - 12.0

func set_camera(index: int) -> void:
	camera_index = index % 3
	var positions: Array[Vector3] = [tuning.camera_rear, tuning.camera_side, tuning.camera_shoulder]
	camera.position = positions[camera_index]
	camera.fov = tuning.camera_fov
	if camera.position.distance_to(tuning.camera_look_at) > 0.01:
		camera.look_at(tuning.camera_look_at)

func _apply_body_settings() -> void:
	sword.mass = tuning.mass_kg
	sword.inertia = Vector3(tuning.inertia_transverse, tuning.inertia_axial, tuning.inertia_transverse)
	sword.center_of_mass = Vector3(0, tuning.center_of_mass_y, 0)
	var material: PhysicsMaterial = PhysicsMaterial.new()
	material.friction = tuning.friction
	material.bounce = 0.0
	sword.physics_material_override = material

func _on_setting_changed(key: StringName) -> void:
	_pending_settings = true
	_layout_panel()
	if key in [&"blade_length", &"blade_width", &"blade_thickness", &"grip_length", &"guard_width"]:
		_rebuild_sword = true

func _physics_process(delta: float) -> void:
	if _pending_settings:
		_pending_settings = false
		_apply_body_settings()
		set_camera(camera_index)
		obstacle.position = tuning.obstacle_position
		(obstacle.get_node("Collision") as CollisionShape3D).shape.set("size", tuning.obstacle_size)
		((obstacle.get_node("Visual") as MeshInstance3D).mesh as BoxMesh).size = tuning.obstacle_size
		if _rebuild_sword:
			_rebuild_sword = false
			for child: Node in sword.get_children():
				sword.remove_child(child)
				child.queue_free()
			SwordVisual.build(sword, tuning)
	input_reader.update_intent()
	if automation:
		planner.advance_to(delta, automated_goal)
	else:
		planner.step(delta, input_reader.consume_motion(), camera.global_basis, input_reader.target_direction())
	controller.step(sword, planner.desired_pose, tuning, delta)
	metrics.sample(delta, sword, planner, controller, tuning)
	target_mesh.position = planner.target
	debug_draw.redraw(sword, planner, controller, tuning)
	_display_elapsed += delta
	if _display_elapsed >= tuning.metrics_interval:
		_display_elapsed = 0.0
		var views: Array[String] = ["Rear", "Side", "Shoulder"]
		overlay.text = "View: %s | Intent: %s (no assist) | %s\nError: %.3f m / %.1f deg | Speed: %.2f m/s\nForce: %.1f / %.1f N | Torque: %.2f / %.1f Nm\nObstacle entries: %d | Last recovery: %.2f s (-1 = none)\nDepth reference Z: %.2f | Desired hilt Z: %.2f" % [views[camera_index], input_reader.intent, "CONTROL" if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else "CURSOR / target held", controller.position_error, rad_to_deg(controller.angle_error), sword.linear_velocity.length(), controller.applied_force.length(), tuning.force_limit, controller.applied_torque.length(), tuning.torque_limit, metrics.contact_entries, metrics.recovery_seconds, planner.target.z, planner.desired_pose.origin.z]

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	var key: InputEventKey = event as InputEventKey
	if not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_F1:
			debug_draw.visible = not debug_draw.visible
			overlay.visible = debug_draw.visible
		KEY_F2:
			panel.visible = not panel.visible
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if panel.visible else Input.MOUSE_MODE_CAPTURED
			input_reader.consume_motion()
			input_reader.discard_next_motion = true
		KEY_TAB, KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
			input_reader.consume_motion()
			input_reader.discard_next_motion = true
		KEY_C:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				set_camera(camera_index + 1)
		KEY_R:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				planner.recenter()
		KEY_F5:
			panel.reset_defaults()

func _close_panel() -> void:
	panel.hide()
	input_reader.consume_motion()
	input_reader.discard_next_motion = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
