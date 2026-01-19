extends Node2D

@export var rotation_speed: float = 1.0

func _process(delta: float) -> void:
	rotate(delta * rotation_speed)
