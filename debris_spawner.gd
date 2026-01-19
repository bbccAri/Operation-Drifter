extends Node2D
class_name DebrisSpawner

#@export var debris = preload("res://floating objects/debris/debris.tscn")
@export var target: Node2D
@export var player: CharacterBody2D
@export var spawn_radius_min: float = 24000.0
@export var spawn_radius_max: float = 80000.0
@export var despawn_time_min: float = 15.0
@export var despawn_time_max: float = 25.0
@export var min_distance_from_player: float = 128.0
@export var max_distance_from_player: float = 32000.0
@export var angle_towards_player_width: float = PI/4
@export var max_debris: int = 500
@export var rarity_chance: float = 0.25
var debris_array: Array = []
@export var scraps_worthless: Array[PackedScene]
@export var scraps_materials: Array[PackedScene]
@export var scraps_salvage: Array[PackedScene]
@export var scraps_valuable: Array[PackedScene]
@export var scraps_priceless: Array[PackedScene]
@export var worthless_pricerange: Vector2i = Vector2i(0, 200)
@export var materials_pricerange: Vector2i = Vector2i(100, 1000)
@export var salvage_pricerange: Vector2i = Vector2i(800, 2500)
@export var valuable_pricerange: Vector2i = Vector2i(2000, 4500)
@export var priceless_pricerange: Vector2i = Vector2i(4000, 8000)
@export var worthless_sizerange: Vector2i = Vector2i(20, 30)
@export var materials_sizerange: Vector2i = Vector2i(10, 20)
@export var salvage_sizerange: Vector2i = Vector2i(15, 40)
@export var valuable_sizerange: Vector2i = Vector2i(30, 60)
@export var priceless_sizerange: Vector2i = Vector2i(50, 100)

enum ScrapRarity {
	Worthless,
	Materials,
	Salvage,
	Valuable,
	Priceless
}

func _process(_delta: float) -> void:
	if debris_array.size() < max_debris:
		spawn_debris()

func spawn_debris():
	var obj: Debris
	var rarity = (spawn_radius_min * rarity_chance)/(randfn(0, spawn_radius_max-spawn_radius_min/4) + spawn_radius_min)
	if randf() <= rarity * 12:
		if randf() <= rarity:
			if randf() <= rarity:
				if randf() <= rarity:
					obj = scraps_priceless.pick_random().instantiate()
					obj.scrap_rarity = ScrapRarity.Priceless
					obj.value = randi_range(priceless_pricerange.x, priceless_pricerange.y)
				else:
					obj = scraps_valuable.pick_random().instantiate()
					obj.scrap_rarity = ScrapRarity.Valuable
					obj.value = randi_range(valuable_pricerange.x, valuable_pricerange.y)
			else:
				obj = scraps_salvage.pick_random().instantiate()
				obj.scrap_rarity = ScrapRarity.Salvage
				obj.value = randi_range(salvage_pricerange.x, salvage_pricerange.y)
		else:
			obj = scraps_materials.pick_random().instantiate()
			obj.scrap_rarity = ScrapRarity.Materials
			obj.value = randi_range(materials_pricerange.x, materials_pricerange.y)
	else:
		obj = scraps_worthless.pick_random().instantiate()
		obj.scrap_rarity = ScrapRarity.Worthless
		obj.value = randi_range(worthless_pricerange.x, worthless_pricerange.y)
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
	obj.debris_spawner = self
	obj.expiration_date = randf_range(despawn_time_min, despawn_time_max)
	debris_array.append(obj)
	
	self.add_child(obj)
