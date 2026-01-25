extends Node2D

var player: Player
var player_in_range: bool = false
@onready var label: RichTextLabel = $RichTextLabel

func enter_tutorial(body: Player):
	player = body

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if player == null:
			enter_tutorial(body)
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
