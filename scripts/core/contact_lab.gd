class_name ContactLab
extends SwordLab

var contact_tuning: ContactTuning
var opponent: StaticBody3D
var hurtbox: Area3D
var detector: BladeHitDetector = BladeHitDetector.new()
var contact_draw: ContactDebugDraw
var contact_overlay: Label
var physical_contact_ticks: int = 0
var physical_contact_entries: int = 0
var contact_slide_distance: float = 0.0
var _previous_sword_position: Vector3
var _previous_contact: bool = false
var _lmb_was_down: bool = false
var _trial_armed: bool = false
var _contact_dirty: bool = false
var _geometry_dirty: bool = false
var _contact_log_elapsed: float = 0.0

func _ready() -> void:
	super._ready()
	contact_tuning = tuning as ContactTuning
	detector.tuning = contact_tuning
	detector.automatic_swing_start = false
	detector.hit_detected.connect(_on_hit)
	# Keep the Phase 1 scene unchanged; its obstacle is not used in this lab.
	obstacle.hide()
	obstacle.collision_layer = 0
	obstacle.collision_mask = 0
	opponent = StaticBody3D.new()
	opponent.name = "OpponentSword"
	opponent.collision_layer = CollisionLayers.OPPONENT_SWORD
	opponent.collision_mask = CollisionLayers.OPPONENT_SWORD_MASK
	add_child(opponent)
	SwordVisual.build(opponent, tuning, Color(0.6, 0.6, 0.65))
	hurtbox = Area3D.new()
	hurtbox.name = "DamageProbe"
	hurtbox.collision_layer = CollisionLayers.HURTBOX
	hurtbox.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "Shape"
	collision.shape = BoxShape3D.new()
	hurtbox.add_child(collision)
	var visual: MeshInstance3D = SwordVisual.box(hurtbox, contact_tuning.hurtbox_size, Vector3.ZERO, Color(0.15, 0.9, 0.3, 0.35))
	visual.name = "Visual"
	(visual.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	add_child(hurtbox)
	_apply_contact_settings()
	contact_draw = ContactDebugDraw.new()
	add_child(contact_draw)
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	contact_overlay = Label.new()
	contact_overlay.name = "ContactMetrics"
	contact_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contact_overlay.add_theme_font_size_override("font_size", 14)
	canvas.add_child(contact_overlay)
	contact_overlay.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	contact_overlay.offset_left = 16
	contact_overlay.offset_top = -112
	contact_overlay.offset_bottom = -12
	help.text = help.text.replace("SWORD LAB", "CONTACT LAB")
	help.text += "\nLMB hold = one hit trial; release to rearm | Green probe: no blocking | Grey sword: physical blocking"
	overlay.position.y = 110
	_previous_sword_position = sword.global_position
	print("CONTACT_LAB_START static opponent; no assist; one hit per target per LMB hold")

func _on_setting_changed(key: StringName) -> void:
	super._on_setting_changed(key)
	_contact_dirty = true
	if key in [&"blade_length", &"blade_width", &"blade_thickness", &"grip_length", &"guard_width"]:
		_geometry_dirty = true

func _apply_contact_settings() -> void:
	opponent.position = contact_tuning.opponent_position
	opponent.rotation_degrees = contact_tuning.opponent_rotation_degrees
	var material: PhysicsMaterial = PhysicsMaterial.new()
	material.friction = contact_tuning.opponent_friction
	material.bounce = 0.0
	opponent.physics_material_override = material
	hurtbox.position = contact_tuning.hurtbox_position
	((hurtbox.get_node("Shape") as CollisionShape3D).shape as BoxShape3D).size = contact_tuning.hurtbox_size
	((hurtbox.get_node("Visual") as MeshInstance3D).mesh as BoxMesh).size = contact_tuning.hurtbox_size

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _contact_dirty:
		_contact_dirty = false
		_apply_contact_settings()
		detector.reset_history()
		if _geometry_dirty:
			_geometry_dirty = false
			for child: Node in opponent.get_children():
				opponent.remove_child(child)
				child.queue_free()
			SwordVisual.build(opponent, tuning, Color(0.6, 0.6, 0.65))
	var base: Vector3 = (sword.get_node("BladeBase") as Marker3D).position
	var tip: Vector3 = (sword.get_node("Tip") as Marker3D).position
	var excluded: Array[RID] = [sword.get_rid()]
	var lmb_down: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if not lmb_down:
		_trial_armed = false
	elif not _lmb_was_down and input_reader.intent == "ATTACK":
		detector.begin_swing()
		_trial_armed = true
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		_trial_armed = false
	_lmb_was_down = lmb_down
	detector.step(get_world_3d().direct_space_state, sword.global_transform, base, tip, delta, _trial_armed and input_reader.intent == "ATTACK", excluded)
	if sword.sword_contact:
		physical_contact_ticks += 1
		if not _previous_contact:
			physical_contact_entries += 1
		else:
			contact_slide_distance += absf((sword.global_position - _previous_sword_position).dot(opponent.global_basis.y))
	_previous_contact = sword.sword_contact
	_previous_sword_position = sword.global_position
	contact_draw.visible = debug_draw.visible
	contact_overlay.visible = debug_draw.visible
	contact_draw.draw_detector(detector, sword, contact_tuning)
	var candidate: String = "none"
	if detector.last_candidate != null:
		var hit: BladeHit = detector.last_candidate
		candidate = "%s / %s | %.2f m/s | alignment %.2f" % [hit.kind, hit.region, hit.speed, hit.alignment]
	contact_overlay.text = "Sword contact: %s | entries %d | sliding %.3f m\nHit trials: %d | accepted events: %d | repeated candidates suppressed: %d\nLast probe contact: %s\nPurple: sample sweeps | Lime: samples | Yellow axis: edge | Pink axis: flat normal\nDetection is separate from blocking; score is diagnostic, not HP." % ["YES" if sword.sword_contact else "no", physical_contact_entries, contact_slide_distance, detector.swing_id, detector.hits, detector.duplicate_candidates, candidate]
	_contact_log_elapsed += delta
	if _contact_log_elapsed >= tuning.log_interval:
		_contact_log_elapsed = 0.0
		print("CONTACT_METRICS ", JSON.stringify({"physical_entries": physical_contact_entries, "contact_ticks": physical_contact_ticks, "slide_m": contact_slide_distance, "trials": detector.swing_id, "hits": detector.hits, "duplicate_candidates_suppressed": detector.duplicate_candidates, "queries_this_tick": detector.query_count, "subdivision_limit_frames": detector.subdivision_limit_frames}))

func _on_hit(hit: BladeHit) -> void:
	print("BLADE_HIT ", JSON.stringify(hit.as_dictionary()))
