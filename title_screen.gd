extends Node2D

var game_scene: PackedScene = preload("res://game.tscn")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().quit()
