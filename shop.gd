extends Node2D

var player: Player
var player_in_range: bool = false
@onready var label: RichTextLabel = $RichTextLabel
var done_tutorial: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func enter_tutorial():
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if player == null:
			player = body
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false

func _process(_delta: float) -> void:
	if player_in_range:
		label.visible = true
		if Input.is_action_just_pressed("Interact"):
			open_shop()
	else:
		label.visible = false

func open_shop():
	if !done_tutorial:
		enter_tutorial()
	else:
		pass
