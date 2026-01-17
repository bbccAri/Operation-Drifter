extends Node2D

@export var target: Node2D
@export var speed: float = 50.0
var distance: float
@export var start_angle: float = 0.0

var current_angle: float = 0.0

func _ready() -> void:
	current_angle = deg_to_rad(randf_range(0.0, 360.0))
	distance = position.distance_to(target.position)

func _process(delta: float) -> void:
	if target == null:
		push_error("No target to orbit set!")
		return
		
	print(position)
		
	current_angle += deg_to_rad(speed) * delta
	
	var x = target.global_position.x + cos(start_angle + current_angle) * distance
	var y = target.global_position.y + sin(start_angle + current_angle) * distance
	
	global_position = Vector2(x, y)
