class_name LabPanel
extends PanelContainer

signal setting_changed(property_name: StringName)
signal close_requested

var defaults_path: String = "res://resources/tuning/sword_tuning.tres"
var first_group: String = ""
var tuning: SwordTuning
var _editors: Dictionary[StringName, SpinBox] = {}
var _style: StyleBoxFlat

func _ready() -> void:
	name = "TuningPanel"
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.035, 0.045, 0.065, tuning.panel_opacity)
	_style.content_margin_left = 12
	_style.content_margin_right = 12
	_style.content_margin_top = 10
	_style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", _style)
	var column: VBoxContainer = VBoxContainer.new()
	add_child(column)
	var close_button: Button = Button.new()
	close_button.name = "CloseTuning"
	close_button.text = "Close tuning [F2]"
	close_button.pressed.connect(func() -> void: close_requested.emit())
	column.add_child(close_button)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var rows: VBoxContainer = VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	var properties: Array[Dictionary] = tuning.get_property_list()
	if not first_group.is_empty():
		for index: int in range(properties.size()):
			if String(properties[index]["name"]) == first_group:
				properties = properties.slice(index) + properties.slice(0, index)
				break
	for info: Dictionary in properties:
		var usage: int = int(info["usage"])
		if usage & PROPERTY_USAGE_GROUP:
			var heading: Label = Label.new()
			heading.text = String(info["name"])
			rows.add_child(heading)
			continue
		if usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var key: StringName = StringName(info["name"])
		if int(info["hint"]) == PROPERTY_HINT_RANGE:
			var bounds: PackedStringArray = String(info["hint_string"]).split(",")
			add_editor(rows, key, float(bounds[0]), float(bounds[1]), float(bounds[2]), -1)
		elif int(info["type"]) == TYPE_VECTOR3:
			var rotation_field: bool = String(key).ends_with("rotation_degrees")
			for axis: int in range(3):
				add_editor(rows, key, -180.0 if rotation_field else (0.05 if String(key).ends_with("size") else -10.0), 180.0 if rotation_field else 10.0, 1.0 if rotation_field else 0.05, axis)
	var reset: Button = Button.new()
	reset.name = "ResetTuning"
	reset.text = "Reset all settings [F5]"
	reset.pressed.connect(reset_defaults)
	column.add_child(reset)

func add_editor(rows: VBoxContainer, key: StringName, minimum: float, maximum: float, increment: float, axis: int) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	label.text = String(key).capitalize() + ((" " + "XYZ"[axis]) if axis >= 0 else "")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var field: SpinBox = SpinBox.new()
	field.name = String(key) + (str(axis) if axis >= 0 else "")
	field.min_value = minimum
	field.max_value = maximum
	field.step = increment
	if axis < 0:
		field.value = float(tuning.get(key))
	else:
		var vector: Vector3 = tuning.get(key)
		field.value = vector[axis]
	field.value_changed.connect(_edit.bind(key, axis))
	row.add_child(label)
	row.add_child(field)
	rows.add_child(row)
	_editors[StringName(field.name)] = field

func _edit(value: float, key: StringName, axis: int) -> void:
	if axis < 0:
		tuning.set(key, int(value) if typeof(tuning.get(key)) == TYPE_INT else value)
	else:
		var vector: Vector3 = tuning.get(key)
		vector[axis] = value
		tuning.set(key, vector)
	_style.bg_color.a = tuning.panel_opacity
	setting_changed.emit(key)
	print("SWORD_TUNING ", key, "=", tuning.get(key))

func reset_defaults() -> void:
	var defaults: SwordTuning = load(defaults_path) as SwordTuning
	for info: Dictionary in defaults.get_property_list():
		if int(info["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var key: StringName = StringName(info["name"])
		if _editors.has(key):
			_editors[key].value = float(defaults.get(key))
		elif int(info["type"]) == TYPE_VECTOR3:
			var vector: Vector3 = defaults.get(key)
			for axis: int in range(3):
				_editors[StringName(String(key) + str(axis))].value = vector[axis]
