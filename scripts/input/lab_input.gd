class_name LabInput
extends Node

var mouse_delta: Vector2 = Vector2.ZERO
var intent: String = "NEUTRAL"
var enabled: bool = true
var discard_next_motion: bool = true

func _unhandled_input(event: InputEvent) -> void:
	if enabled and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		if discard_next_motion:
			discard_next_motion = false
			return
		mouse_delta += (event as InputEventMouseMotion).relative

func consume_motion() -> Vector2:
	var result: Vector2 = mouse_delta
	mouse_delta = Vector2.ZERO
	return result

func update_intent() -> void:
	intent = "NEUTRAL"
	if not enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		intent = "DEFEND"
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		intent = "ATTACK"

func target_direction() -> Vector3:
	if not enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return Vector3.ZERO
	return Vector3(
		float(Input.is_physical_key_pressed(KEY_L)) - float(Input.is_physical_key_pressed(KEY_J)),
		float(Input.is_physical_key_pressed(KEY_U)) - float(Input.is_physical_key_pressed(KEY_O)),
		float(Input.is_physical_key_pressed(KEY_K)) - float(Input.is_physical_key_pressed(KEY_I))
	).limit_length()
