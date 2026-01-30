extends Node2D

@export var player: Player
var player_in_range: bool = true
@onready var label: RichTextLabel = $RichTextLabel
@export var text_tags_start: String = "[center][wave amp=8.0 freq=4.0 connected=1][pulse freq=0.5 color=#ffffff80 ease=-2.0]"
@export var text_tags_end: String = "[/pulse][/wave][/center]"
@export var shop_hint: String = "[E] Interact"
@export var sell_hint: String = "[F] Sell"
var done_tutorial: bool = false
@onready var money_particles: GPUParticles2D = $GPUParticles2D
var in_shop: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D2.play("default")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_dialogic_signal(arg):
	if arg == "sell":
		sell()

func _on_timeline_ended():
	exit_shop()

func enter_tutorial():
	run_dialogue("tutorial")
	done_tutorial = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if player == null:
			player = body
		player_in_range = true
		player.near_shop = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		player.near_shop = false

func _process(_delta: float) -> void:
	if player_in_range:
		if player.cargo_carrying > 0:
			label.text = text_tags_start + shop_hint + "\n" + sell_hint + text_tags_end
		else:
			label.text = text_tags_start + shop_hint + text_tags_end
		label.visible = true
		print("player in range")
		if Input.is_action_just_pressed("Interact"):
			open_shop()
		if Input.is_action_just_pressed("Confirm") and player.cargo_carrying > 0:
			sell()
	else:
		label.visible = false

func open_shop():
	if in_shop:
		return
	
	in_shop = true
	
	if !done_tutorial:
		enter_tutorial()
	else:
		run_dialogue("shopNormal")

func exit_shop():
	await get_tree().create_timer(0.2).timeout
	in_shop = false
	done_tutorial = true

func run_dialogue(dialogue_name: String):
	Dialogic.start(dialogue_name)

func sell():
	money_particles.emitting = true
	if player != null:
		player.money += player.cargo_value
		player.cargo_value = 0
		player.cargo_carrying = 0


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body is Player:
		if player == null:
			player = body
		player.in_safe_zone = true

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body is Player:
		player.in_safe_zone = false
