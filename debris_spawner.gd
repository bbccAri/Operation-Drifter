extends Node2D
class_name DebrisSpawner

@export var debris = preload("res://debris.tscn")
@export var target: Node2D
@export var player: CharacterBody2D
@export var spawn_radius_min: float = 24000.0
@export var spawn_radius_max: float = 64000.0
@export var despawn_time_min: float = 15.0
@export var despawn_time_max: float = 25.0
@export var max_debris: int = 500
@export var rarity_chance: float = 0.25
var debris_array: Array = []
@export var scraps_worthless: Array
@export var scraps_materials: Array
@export var scraps_salvage: Array
@export var scraps_valuable: Array
@export var scraps_priceless: Array

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
	var obj: Debris = debris.instantiate()
	var angle = randf_range(0.0, TAU)
	var spawn_distance = abs(randfn(0, (spawn_radius_max-spawn_radius_min)/2)) + spawn_radius_min
	var rarity = (spawn_radius_min * rarity_chance)/(randfn(0, spawn_radius_max-spawn_radius_min/4) + spawn_radius_min)
	if randf() <= rarity * 12:
		if randf() <= rarity:
			if randf() <= rarity:
				if randf() <= rarity:
					obj.scrap_rarity = ScrapRarity.Priceless
					#obj.sprite = scraps_priceless.pick_random()#TODO:change from sprite bc collision also needs to match
				else:
					obj.scrap_rarity = ScrapRarity.Valuable
					#obj.sprite = scraps_valuable.pick_random()
			else:
				obj.scrap_rarity = ScrapRarity.Salvage
				#obj.sprite = scraps_salvage.pick_random()
		else:
			obj.scrap_rarity = ScrapRarity.Materials
			#obj.sprite = scraps_materials.pick_random()
	else:
		obj.scrap_rarity = ScrapRarity.Worthless
		#obj.sprite = scraps_worthless.pick_random()
	var pos_to_spawn: Vector2 = global_position + Vector2.from_angle(angle) * spawn_distance
	while pos_to_spawn.distance_to(player.global_position) <= 96.0:
		pos_to_spawn = global_position + Vector2.from_angle(angle) * spawn_distance
	obj.global_position = pos_to_spawn
	obj.rotation = randf_range(0.0, TAU)
	obj.orbit_target = target
	obj.player = player
	
	self.add_child(obj)
