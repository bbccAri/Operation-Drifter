extends RichTextLabel

@export var target: Node2D
@export var offset: Vector2 = Vector2(-32, 64)

func _process(_delta: float) -> void:
	global_position = target.global_position + offset
