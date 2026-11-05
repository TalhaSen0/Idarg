class_name ContactTuning
extends SwordTuning

@export_group("Contact lab")
@export var opponent_position: Vector3 = Vector3(-0.2, 1.75, -0.45)
@export var opponent_rotation_degrees: Vector3 = Vector3(0.0, 0.0, -90.0)
@export_range(0.0, 1.0, 0.05) var opponent_friction: float = 0.3
@export var hurtbox_position: Vector3 = Vector3(-0.8, 1.6, -0.5)
@export var hurtbox_size: Vector3 = Vector3(0.15, 0.7, 0.5)
@export_group("Swept detection")
@export_range(3, 65, 2) var blade_samples: int = 25
@export_range(0.003, 0.05, 0.001) var sweep_radius: float = 0.02
@export_range(1.0, 30.0, 1.0) var rotation_step_degrees: float = 5.0
@export_range(1, 64, 1) var max_rotation_steps: int = 36
@export_range(1, 32, 1) var query_max_results: int = 16
@export_group("Hit qualification")
@export_range(0.05, 5.0, 0.05) var minimum_hit_speed: float = 0.25
@export_range(0.1, 1.0, 0.05) var minimum_edge_alignment: float = 0.65
@export_range(0.1, 1.0, 0.05) var minimum_tip_alignment: float = 0.75
@export_range(0.5, 0.99, 0.01) var tip_start_fraction: float = 0.85
@export_range(0.1, 0.7, 0.05) var forte_end_fraction: float = 0.35
@export_range(0.1, 2.0, 0.1) var forte_weight: float = 0.6
@export_range(0.1, 2.0, 0.1) var foible_weight: float = 1.0
@export_range(0.1, 2.0, 0.1) var tip_weight: float = 1.2
@export_range(0.1, 10.0, 0.1) var score_scale: float = 1.0
