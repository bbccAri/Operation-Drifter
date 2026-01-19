extends RigidBody2D
class_name Debris

@export var orbit_target: Node2D
var speed: float = 200
@export var speed_factor: float = 64
var distance: float
var perpendicular_direction: Vector2
var undisturbed: bool = true
@export var gravity_factor: float = 0.025

#var debris_spawner: Node2D
var player: CharacterBody2D
@export var despawn_distance: float = 128.0
var count_up_timer: float = 0.0
var expiration_date: float = 20.0
var scrap_rarity: DebrisSpawner.ScrapRarity = DebrisSpawner.ScrapRarity.Materials
@onready var sprite: Sprite2D = $Sprite2D

func PerpendicularClockwise(vector2: Vector2) -> Vector2:
	return Vector2(vector2.y, -vector2.x)

func PerpendicularCounterClockwise(vector2: Vector2) -> Vector2:
	return Vector2(-vector2.y, vector2.x)

func _ready() -> void:
	gravity_scale = gravity_factor
	var dir_to_target = global_position.direction_to(orbit_target.global_position)
	perpendicular_direction = PerpendicularCounterClockwise(dir_to_target)
	linear_velocity = perpendicular_direction * speed

func _physics_process(delta: float) -> void:
	if undisturbed:
		distance = global_position.distance_to(orbit_target.global_position)
		var dir_to_target = global_position.direction_to(orbit_target.global_position)
		perpendicular_direction = PerpendicularCounterClockwise(dir_to_target)
		speed = speed_factor * distance/10000
		#linear_velocity = perpendicular_direction * starting_speed
		apply_force(perpendicular_direction * speed * delta)
		
func _process(delta: float) -> void:
	#if debris_spawner != null:
		#if global_position.distance_squared_to(debris_spawner.global_position) >= pow(despawn_distance, 2):
			#queue_free()
	if player != null:
		if count_up_timer >= expiration_date:
			if global_position.distance_squared_to(player.global_position) >= pow(despawn_distance, 2):
				queue_free()
		elif player != null:
			count_up_timer += delta

func grab():
	undisturbed = false
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO
	freeze = true
	
func ungrab():
	gravity_scale = gravity_factor
	freeze = false
