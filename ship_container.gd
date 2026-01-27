extends Node2D
class_name Ship

@onready var ship_body: CharacterBody2D = $Ship
@onready var sprite: Sprite2D = $Ship/Sprite2D
@onready var explode_particles: GPUParticles2D = $Ship/DebrisExplodeParticles
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
@export var gravity_resistance_amount: float = .2
@export var gravity_resistance_level: int = 1
@export var gravity_resistance_max_level: int = 5
@export var gravity_resistance_price: int = 2500
@export var exit_distance: float = 16.0
@onready var particle_trail: GPUParticles2D = $Ship/TrailParticles
var health: int = 5
@export var maxHealth: int = 5
var exploding: bool = false

@export var normalSprite: Texture2D = preload("res://sprites/playership.png")
@export var batteredSprite: Texture2D
@export var brokenSprite: Texture2D

var damage_resistance_level: int = 0
@export var damage_resistance_max_level: int = 2
@export var damage_resistance_price: int = 1000
var ship_thruster_power_level: int = 0
@export var ship_thruster_power_max_level: int = 5
@export var ship_thruster_power_price: int = 2000
@export var ship_thruster_power_amount: float = 0.2
@export var repair_price: int = 2500

func _ready() -> void:
	DialogicToPlayer.ship = self

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
	if player.in_dialogue:
		direction = Vector2.ZERO
	ship_body.rotation_degrees += direction.x * rotation_speed * delta
	ship_body.velocity = lerp(ship_body.velocity, Vector2(0, direction.normalized().y).rotated(ship_body.rotation) * (speed * (1 + ship_thruster_power_level * ship_thruster_power_amount)), delta * acceleration)
	ship_body.velocity += ship_body.get_gravity() * (1.0 - gravity_resistance_amount * gravity_resistance_level)
	ship_body.move_and_slide()
	player.global_position = ship_body.global_position

func _process(_delta: float) -> void:
	if playerClose and !playerInside:
		if Input.is_action_just_pressed("Interact") and !player.near_shop:
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
			if player.in_dialogue:
				input = Vector2.ZERO
			particle_trail.amount_ratio = max(abs(input.x), abs(input.y))
			if Input.is_action_just_pressed("Interact") and !player.near_shop:
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
	if body is Player and not exploding:
		playerClose = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		playerClose = false

func upgrade_gravity_resistance():
	if gravity_resistance_level < gravity_resistance_max_level:
		gravity_resistance_level += 1

func upgrade_damage_resistance():
	if damage_resistance_level < damage_resistance_max_level:
		damage_resistance_level += 1

func upgrade_thruster_power():
	if ship_thruster_power_level < ship_thruster_power_max_level:
		ship_thruster_power_level += 1

func repair():
	health = maxHealth
	update_sprite()

func update_sprite():
	if health <= 1:
		sprite.texture = brokenSprite
	elif health < maxHealth:
		sprite.texture = batteredSprite
	else:
		sprite.texture = normalSprite

func take_damage(amount: int):
	health -= (amount - damage_resistance_level)
	update_sprite()
	if health <= 0:
		health = 0
		explode()

func explode():
	if not exploding:
		exploding = true
		sprite.visible = false
		ship_body.process_mode = Node.PROCESS_MODE_DISABLED
		if player.in_ship:
			exit_ship()
		playerClose = false
		explode_particles.restart()
		await get_tree().create_timer(4, false, false, false).timeout
		queue_free()
