class_name TargetDepthStrategy
extends DepthStrategy

func desired_depth(target: Vector3, _current_depth: float, tuning: SwordTuning) -> float:
	return clampf(target.z + tuning.depth_offset, tuning.depth_min, tuning.depth_max)
