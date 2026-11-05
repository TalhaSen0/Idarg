class_name DebugOverlay
extends Label

func show_sample(uptime: float, ticks: int, fps: float, physics_ms: float) -> void:
	text = ("DEBUG | Phase 0\nSimulation: %.1f s | Physics ticks: %d\n"
		+ "FPS: %.0f | Physics CPU: %.3f ms\n"
		+ "Tracking / overshoot / contacts / assist: N/A (not implemented)") % [
		uptime, ticks, fps, physics_ms]
