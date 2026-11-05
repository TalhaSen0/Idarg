class_name SwordTuning
extends Resource

@export_group("Controller")
@export_range(10.0, 300.0, 5.0) var position_gain: float = 100.0
@export_range(2.0, 50.0, 1.0) var position_damping: float = 20.0
@export_range(10.0, 300.0, 5.0) var rotation_gain: float = 120.0
@export_range(2.0, 50.0, 1.0) var rotation_damping: float = 22.0
@export_range(10.0, 250.0, 5.0) var force_limit: float = 100.0
@export_range(0.5, 30.0, 0.5) var torque_limit: float = 12.0
@export_group("Sword")
@export_range(0.5, 3.0, 0.05) var mass_kg: float = 1.3
@export_range(0.03, 0.5, 0.01) var inertia_transverse: float = 0.16
@export_range(0.001, 0.03, 0.001) var inertia_axial: float = 0.004
@export_range(0.0, 0.6, 0.01) var center_of_mass_y: float = 0.32
@export_range(0.7, 1.3, 0.01) var blade_length: float = 0.95
@export_range(0.02, 0.09, 0.005) var blade_width: float = 0.05
@export_range(0.008, 0.04, 0.002) var blade_thickness: float = 0.012
@export_range(0.15, 0.35, 0.01) var grip_length: float = 0.24
@export_range(0.15, 0.4, 0.01) var guard_width: float = 0.26
@export_range(0.0, 1.0, 0.05) var friction: float = 0.4
@export_group("Mouse and desired motion")
@export_range(0.0005, 0.01, 0.0005) var mouse_sensitivity: float = 0.003
@export_range(0.2, 2.0, 0.05) var horizontal_range: float = 1.1
@export_range(0.2, 1.2, 0.05) var vertical_range: float = 0.65
@export_range(0.5, 6.0, 0.1) var desired_speed_limit: float = 3.0
@export_range(0.5, 10.0, 0.1) var desired_angular_speed: float = 4.0
@export_range(0.0, 60.0, 1.0) var mouse_tilt_degrees: float = 35.0
@export_range(-80.0, -10.0, 1.0) var rest_pitch_degrees: float = -45.0
@export_range(0.8, 2.0, 0.05) var hilt_height: float = 1.25
@export_group("Depth strategy")
@export_range(0.1, 1.5, 0.05) var depth_offset: float = 0.75
@export_range(-1.5, 0.0, 0.05) var depth_min: float = -0.65
@export_range(0.05, 1.5, 0.05) var depth_max: float = 0.8
@export_range(0.1, 2.0, 0.05) var target_move_speed: float = 0.6
@export var target_start: Vector3 = Vector3(0.0, 1.5, -0.8)
@export var target_min: Vector3 = Vector3(-2.0, 0.3, -2.0)
@export var target_max: Vector3 = Vector3(2.0, 3.0, 0.5)
@export_group("View and lab")
@export_range(30.0, 90.0, 1.0) var camera_fov: float = 52.0
@export var camera_rear: Vector3 = Vector3(0.0, 2.2, 5.2)
@export var camera_side: Vector3 = Vector3(-4.8, 2.2, 0.8)
@export var camera_shoulder: Vector3 = Vector3(2.6, 2.5, 4.5)
@export var camera_look_at: Vector3 = Vector3(0.0, 1.55, -0.3)
@export var obstacle_position: Vector3 = Vector3(0.9, 1.2, -0.55)
@export var obstacle_size: Vector3 = Vector3(0.3, 2.4, 0.65)
@export_group("Diagnostics")
@export_range(0.1, 2.0, 0.1) var metrics_interval: float = 0.2
@export_range(0.5, 10.0, 0.5) var log_interval: float = 2.0
@export_range(0.01, 0.2, 0.01) var settled_position: float = 0.04
@export_range(1.0, 15.0, 1.0) var settled_angle_degrees: float = 3.0
@export_range(0.05, 0.5, 0.05) var settled_speed: float = 0.15
@export_range(0.1, 1.0, 0.1) var settled_hold: float = 0.3
@export_range(0.001, 0.05, 0.001) var force_draw_scale: float = 0.008
@export_range(0.01, 0.2, 0.01) var torque_draw_scale: float = 0.06
@export_range(0.3, 0.95, 0.05) var panel_opacity: float = 0.75

@export_range(280.0, 480.0, 10.0) var panel_width: float = 360.0
@export_range(0.35, 0.8, 0.05) var panel_height_fraction: float = 0.65
