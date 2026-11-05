class_name LabMetrics
extends RefCounted

var peak_error: float = 0.0
var sum_squared_error: float = 0.0
var samples: int = 0
var contact_entries: int = 0
var recovery_seconds: float = -1.0
var _contact_last: bool = false
var _recovering: bool = false
var _recovery_elapsed: float = 0.0
var _settled_elapsed: float = 0.0
var _log_elapsed: float = 0.0

func sample(delta: float, body: SwordBody, planner: SwordMotionPlanner, pd: PhysicalSwordController, tuning: SwordTuning) -> void:
	samples += 1
	peak_error = maxf(peak_error, pd.position_error)
	sum_squared_error += pd.position_error * pd.position_error
	if body.obstacle_contact and not _contact_last:
		contact_entries += 1
		_recovering = false
	if _contact_last and not body.obstacle_contact:
		_recovering = true
		_recovery_elapsed = 0.0
		_settled_elapsed = 0.0
	_contact_last = body.obstacle_contact
	if _recovering:
		_recovery_elapsed += delta
		var settled: bool = pd.position_error < tuning.settled_position and rad_to_deg(pd.angle_error) < tuning.settled_angle_degrees and body.linear_velocity.length() < tuning.settled_speed and planner.desired_velocity.length() < tuning.settled_speed
		_settled_elapsed = _settled_elapsed + delta if settled else 0.0
		if _settled_elapsed >= tuning.settled_hold:
			recovery_seconds = _recovery_elapsed
			_recovering = false
			print("SWORD_RECOVERY seconds=", recovery_seconds)
	_log_elapsed += delta
	if _log_elapsed >= tuning.log_interval:
		_log_elapsed = 0.0
		print("SWORD_METRICS ", JSON.stringify({
			"error_m": pd.position_error, "angle_deg": rad_to_deg(pd.angle_error),
			"rms_m": sqrt(sum_squared_error / float(samples)), "peak_error_m": peak_error,
			"speed_m_s": body.linear_velocity.length(), "desired_speed_m_s": planner.desired_velocity.length(),
			"force_n": pd.applied_force.length(), "torque_nm": pd.applied_torque.length(),
			"contact_entries": contact_entries, "recovery_seconds": recovery_seconds}))
