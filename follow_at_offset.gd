extends Node2D

@export var target: Node2D
@export var offset: Vector2 = Vector2(-64, 64)

func _process(_delta: float) -> void:
	global_position = target.global_position + offset
