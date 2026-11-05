class_name TuningPanel
extends VBoxContainer

signal setting_changed(property_name: StringName, value: float)

var tuning: DebugTuning
var _controls: Dictionary[StringName, SpinBox] = {}

func _ready() -> void:
	var heading: Label = Label.new()
	heading.text = "LIVE DEBUG TUNING (session only)"
	add_child(heading)
	# Export metadata is the single source for editable bounds and increments.
	for info: Dictionary in tuning.get_property_list():
		if int(info["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		if int(info["hint"]) != PROPERTY_HINT_RANGE:
			continue
		var property_name: StringName = StringName(info["name"])
		var bounds: PackedStringArray = String(info["hint_string"]).split(",")
		var row: HBoxContainer = HBoxContainer.new()
		var label: Label = Label.new()
		label.text = String(property_name).capitalize()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var field: SpinBox = SpinBox.new()
		field.name = String(property_name)
		field.min_value = float(bounds[0])
		field.max_value = float(bounds[1])
		field.step = float(bounds[2])
		field.value = float(tuning.get(property_name))
		field.value_changed.connect(_on_value_changed.bind(property_name))
		row.add_child(label)
		row.add_child(field)
		add_child(row)
		_controls[property_name] = field
	var reset: Button = Button.new()
	reset.text = "Reset debug defaults"
	reset.pressed.connect(reset_defaults)
	add_child(reset)

func _on_value_changed(value: float, property_name: StringName) -> void:
	tuning.set(property_name, value)
	tuning.emit_changed()
	setting_changed.emit(property_name, value)

func reset_defaults() -> void:
	var defaults: DebugTuning = load("res://resources/tuning/debug_tuning.tres") as DebugTuning
	for property_name: StringName in _controls:
		_controls[property_name].value = float(defaults.get(property_name))
