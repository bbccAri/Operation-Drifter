extends RigidBody2D

@export var orbit_target: Node2D
var speed: float = 200
@export var speed_factor: float = 64
var distance: float
var perpendicular_direction: Vector2
var undisturbed: bool = true

func PerpendicularClockwise(vector2: Vector2) -> Vector2:
	return Vector2(vector2.y, -vector2.x)

func PerpendicularCounterClockwise(vector2: Vector2) -> Vector2:
	return Vector2(-vector2.y, vector2.x)

func _ready() -> void:
	gravity_scale = 0.025

func _physics_process(delta: float) -> void:
	distance = global_position.distance_to(orbit_target.global_position)
	var dir_to_target = global_position.direction_to(orbit_target.global_position)
	perpendicular_direction = PerpendicularCounterClockwise(dir_to_target)
	speed = speed_factor * distance/10000
	#linear_velocity = perpendicular_direction * starting_speed
	apply_force(perpendicular_direction * speed * delta)

func grab():
	undisturbed = false
	gravity_scale = 0.0
	
func ungrab():
	gravity_scale = 1.0
