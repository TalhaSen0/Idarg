class_name MetricsLogger
extends Node

signal sampled(uptime: float, ticks: int, fps: float, physics_ms: float)

var tuning: DebugTuning
var uptime: float = 0.0
var ticks: int = 0
var _refresh_elapsed: float = 0.0
var _log_elapsed: float = 0.0

func _ready() -> void:
	print("PHASE0_START engine=", Engine.get_version_info()["string"])
	print("Combat metrics unavailable: no sword, contacts, or assist implemented.")

func _physics_process(delta: float) -> void:
	uptime += delta
	ticks += 1
	_refresh_elapsed += delta
	_log_elapsed += delta
	if _refresh_elapsed >= tuning.refresh_seconds:
		_refresh_elapsed = 0.0
		sampled.emit(uptime, ticks, Performance.get_monitor(Performance.TIME_FPS),
			Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
	if _log_elapsed >= tuning.log_seconds:
		_log_elapsed = 0.0
		print("PHASE0_METRICS ", JSON.stringify({
			"simulation_seconds": uptime, "physics_ticks": ticks,
			"fps": Performance.get_monitor(Performance.TIME_FPS),
			"physics_ms": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
			"log_interval_seconds": tuning.log_seconds
		}))
