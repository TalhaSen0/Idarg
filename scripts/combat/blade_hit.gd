class_name BladeHit
extends RefCounted

var target_id: int = 0
var swing_id: int = 0
var position: Vector3 = Vector3.ZERO
var speed: float = 0.0
var alignment: float = 0.0
var blade_fraction: float = 0.0
var region: String = "forte"
var kind: String = "flat"
var score: float = 0.0

func as_dictionary() -> Dictionary:
	return {"target_id": target_id, "swing_id": swing_id, "position": position,
		"speed_m_s": speed, "alignment": alignment, "blade_fraction": blade_fraction,
		"region": region, "kind": kind, "score": score}
