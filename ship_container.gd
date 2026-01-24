extends Node2D

@onready var ship_body: CharacterBody2D = $Ship
@export var player: Player
@export var text_tags_start: String = "[center][wave amp=8.0 freq=4.0 connected=1][pulse freq=0.5 color=#ffffff80 ease=-2.0]"
@export var text_tags_end: String = "[/pulse][/wave][/center]"
@onready var enter_hint_label: RichTextLabel = $RichTextLabel
@export var enter_hint: String = "[E] Enter"
@export var load_cargo_hint: String = "[F] Store Cargo"
var playerClose: bool = false
var playerInside: bool = false
@export var speed: float = 1000
@export var rotation_speed: float = 100
@export var acceleration: float = 3
@export var gravity_resistance: float = 1.5
@export var exit_distance: float = 16.0
@onready var particle_trail: GPUParticles2D = $Ship/TrailParticles

func get_movement_input():
	var input = Vector2()
	if Input.is_action_pressed('Move_Right'):
		input.x += 1
	if Input.is_action_pressed('Move_Left'):
		input.x -= 1
	if Input.is_action_pressed('Move_Down'):
		input.y += 1
	if Input.is_action_pressed('Move_Up'):
		input.y -= 1
	return input

func _physics_process(delta: float) -> void:
	if !playerInside: return
	
	var direction = get_movement_input()
	ship_body.rotation_degrees += direction.x * rotation_speed * delta
	ship_body.velocity = lerp(ship_body.velocity, Vector2(0, direction.normalized().y).rotated(ship_body.rotation) * speed, delta * acceleration)
	ship_body.velocity += ship_body.get_gravity() * gravity_resistance
	ship_body.move_and_slide()
	player.global_position = ship_body.global_position

func _process(_delta: float) -> void:
	if playerClose and !playerInside:
		if Input.is_action_just_pressed("Interact"):
			enter_ship()
		if Input.is_action_just_pressed("Confirm"):
			if player.cargo_capacity - player.cargo_carrying >= player.grabbed_object.cargo_size:
				player.store_object()
		if player.grabbed_object != null:
			enter_hint_label.text = text_tags_start + enter_hint + "\n" + load_cargo_hint + "\n" + str(player.cargo_carrying) + "/" + str(player.cargo_capacity) + text_tags_end
		else:
			enter_hint_label.text = text_tags_start + enter_hint + "\n" + str(player.cargo_carrying) + "/" + str(player.cargo_capacity) + text_tags_end
		enter_hint_label.visible = true
	else:
		enter_hint_label.visible = false
		if playerInside:
			var input = get_movement_input()
			particle_trail.amount_ratio = max(abs(input.x), abs(input.y))
			if Input.is_action_just_pressed("Interact"):
				exit_ship()
		else:
			particle_trail.amount_ratio = 0.0

func enter_ship():
	ship_body.add_collision_exception_with(player)
	player.enter_ship()
	playerInside = true

func exit_ship():
	playerInside = false
	player.exit_ship()
	ship_body.remove_collision_exception_with(player)
	player.rotation = ship_body.rotation
	player.global_position = ship_body.global_position + Vector2.RIGHT * exit_distance

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		playerClose = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		playerClose = false
