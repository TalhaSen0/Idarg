extends Node

const DEFAULT_TUNING: DebugTuning = preload("res://resources/tuning/debug_tuning.tres")

var tuning: DebugTuning
var overlay: DebugOverlay
var panel: TuningPanel

func _ready() -> void:
	tuning = DEFAULT_TUNING.duplicate() as DebugTuning
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	margin.add_child(column)
	var title: Label = Label.new()
	title.text = "IDARG | Phase 0 - diagnostics scaffold"
	column.add_child(title)
	var help: Label = Label.new()
	help.text = "F1: debug overlay | F2: tuning panel | F5: reset debug defaults\nNo sword or character yet. Phase 1 requires playtest approval."
	column.add_child(help)
	overlay = DebugOverlay.new()
	overlay.show_sample(0.0, 0, 0.0, 0.0)
	column.add_child(overlay)
	panel = TuningPanel.new()
	panel.tuning = tuning
	panel.setting_changed.connect(_on_setting_changed)
	column.add_child(panel)
	var logger: MetricsLogger = MetricsLogger.new()
	logger.tuning = tuning
	logger.sampled.connect(overlay.show_sample)
	add_child(logger)
	_apply_tuning()

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_F1:
			overlay.visible = not overlay.visible
		KEY_F2:
			panel.visible = not panel.visible
		KEY_F5:
			panel.reset_defaults()

func _on_setting_changed(property_name: StringName, value: float) -> void:
	_apply_tuning()
	print("PHASE0_TUNING ", property_name, "=", value)

func _apply_tuning() -> void:
	overlay.modulate.a = tuning.overlay_opacity
