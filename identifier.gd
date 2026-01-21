extends Node2D

var selected_value: int = 0
var selected_size: int = 10
var overlapping: Array[Debris]
var target: Debris
@onready var indicator: Node2D = $Indicator
@onready var label: RichTextLabel = $Indicator/RichTextLabel
@export var text_tags_start: String = "[center][wave amp=8.0 freq=4.0 connected=1][pulse freq=0.5 color=#ffffff40 ease=-2.0]"
@export var text_tags_end: String = "[/pulse][/wave][/center]"
@onready var anim: AnimatedSprite2D = $Indicator/AnimatedSprite2D
@export var player: Player

func _ready() -> void:
	anim.play("default")

func _process(_delta: float) -> void:
	global_position = player.global_position
	if Input.is_action_pressed("Scan") and !overlapping.is_empty() and target != null:
		update_target()
		visible = true
		indicator.global_position = target.global_position
	else:
		visible = false

func update_target():
	if player.grabbed_object != null:
		target = player.grabbed_object
		return
	if overlapping.is_empty():
		target = null
		label.text = ""
		visible = false
		return
	var closest: Debris = overlapping[0]
	for debris in overlapping:
		if global_position.distance_squared_to(debris.global_position) < global_position.distance_squared_to(closest.global_position):
			closest = debris
	target = closest
	label.text = text_tags_start + "$" + str(target.value) + "\nSize: " + str(target.cargo_size)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Debris:
		overlapping.append(body)
		update_target()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Debris:
		overlapping.erase(body)
		update_target()
