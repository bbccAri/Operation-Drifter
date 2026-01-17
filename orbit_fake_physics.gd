extends RigidBody2D

@export var orbit_target: Node2D
@export var starting_speed: float = 50
var distance: float
var perpendicular_direction: Vector2
var undisturbed: bool = true

func PerpendicularClockwise(vector2: Vector2) -> Vector2:
	return Vector2(vector2.y, -vector2.x)

func PerpendicularCounterClockwise(vector2: Vector2) -> Vector2:
	return Vector2(-vector2.y, vector2.x)

func _physics_process(delta: float) -> void:
	distance = global_position.distance_to(orbit_target.global_position)
	var dir_to_target = global_position.direction_to(orbit_target.global_position)
	perpendicular_direction = PerpendicularCounterClockwise(dir_to_target)
	#linear_velocity = perpendicular_direction * starting_speed
	apply_force(perpendicular_direction * starting_speed * delta)

func grab():
	undisturbed = false
	gravity_scale = 0.0
	
func ungrab():
	gravity_scale = 1.0
