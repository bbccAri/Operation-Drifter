extends Node2D
class_name AsteroidSpawner

#@export var asteroid = preload("res://floating objects/asteroids/asteroid.tscn")
@export var asteroid_variants: Array[PackedScene]
@export var target: Node2D
@export var player: CharacterBody2D
@export var spawn_radius_min: float = 24000.0
@export var spawn_radius_max: float = 80000.0
@export var despawn_time_min: float = 15.0
@export var despawn_time_max: float = 25.0
@export var min_distance_from_player: float = 128.0
@export var max_distance_from_player: float = 32000.0
@export var angle_towards_player_width: float = PI/4
@export var max_asteroid: int = 500
@export var rarity_chance: float = 0.25
var asteroid_array: Array = []

func _process(_delta: float) -> void:
	if asteroid_array.size() < max_asteroid:
		spawn_asteroid()

func spawn_asteroid():
	var obj: Asteroid = asteroid_variants.pick_random().instantiate()
	var angle_to_player = target.get_angle_to(player.global_position)
	var angle = randf_range(angle_to_player - angle_towards_player_width, angle_to_player + angle_towards_player_width)#randf_range(0.0, TAU)
	var spawn_distance = abs(randfn(0, (spawn_radius_max-spawn_radius_min)/2)) + spawn_radius_min
	var pos_to_spawn: Vector2 = global_position + Vector2.from_angle(angle) * spawn_distance
	while pos_to_spawn.distance_to(player.global_position) <= 128.0:
		pos_to_spawn = global_position + Vector2.from_angle(angle) * spawn_distance
	obj.position = pos_to_spawn
	obj.rotation = randf_range(0.0, TAU)
	obj.orbit_target = target
	obj.player = player
	obj.asteroid_spawner = self
	obj.expiration_date = randf_range(despawn_time_min, despawn_time_max)
	asteroid_array.append(obj)
	
	self.add_child(obj)
