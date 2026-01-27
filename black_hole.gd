extends Node2D

@export var player: Player


func _on_death_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player.die()
