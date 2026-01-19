extends Node2D

@export var debris = preload("res://debris.tscn")
@export var target: Node2D
@export var spawn_radius_min: float = 1600.0
@export var spawn_radius_max: float = 2400.0
@export var despawn_distance: float = 3200.0
var count_up_time: float = 0.0
var bh_scaling: float = 0.0
@export var base_spawn_wait: float = .05
var spawn_wait: float = .05
@export var rarity_chance: float = 0.05

func update_timer():
	if bh_scaling <= 0.01:
		spawn_wait = 500
	else:
		spawn_wait = base_spawn_wait / bh_scaling

func _process(delta: float) -> void:
	count_up_time += delta
	var distance = global_position.distance_to(target.global_position)
	if distance >= 64000:
		bh_scaling = 0.0
	elif distance >= 20000:
		bh_scaling = 64000 / (distance) - 1.0
	else:
		bh_scaling = 3.2
	update_timer()
	if count_up_time >= spawn_wait:
		count_up_time -= spawn_wait
		spawn_debris()

func spawn_debris():
	var obj: Debris = debris.instantiate()
	var angle = randf_range(0.0, TAU)
	var spawn_distance = randf_range(spawn_radius_min, spawn_radius_max)
	obj.global_position = global_position + Vector2.from_angle(angle) * spawn_distance
	obj.rotation = randf_range(0.0, TAU)
	obj.orbit_target = target
	obj.despawn_distance = despawn_distance
	#obj.debris_spawner = self
	get_tree().current_scene.add_child(obj)
