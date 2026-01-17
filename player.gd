extends CharacterBody2D

enum CharState {
	IDLE,
	MOVE,
	GRAB
}

@export var speed: float = 800
@export var rotation_speed: float = 200
@export var acceleration: float = 5
var current_state: CharState = CharState.IDLE
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var black_hole: Node2D
@onready var cam: Camera2D = $Camera2D
@export var zoom_speed: float = 10
@export var gravity_resistance: float = 1.0
@onready var particle_trail: GPUParticles2D = $TrailParticles

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

func _physics_process(delta):
	var direction = get_movement_input()
	rotation_degrees += direction.x * rotation_speed * delta
	velocity = lerp(velocity, Vector2(0, direction.normalized().y).rotated(rotation) * speed, delta * acceleration)
	velocity += get_gravity() * gravity_resistance
	move_and_slide()
	
func _process(delta: float) -> void:
	var bh_distance = global_position.distance_to(black_hole.global_position)
	black_hole_slow(bh_distance)
	black_hole_zoom(bh_distance, delta)
	var input = get_movement_input()
	if Input.is_action_just_pressed("Interact"):
		if current_state != CharState.GRAB:
			current_state = CharState.GRAB
		else:
			current_state = CharState.IDLE
	if input != Vector2.ZERO and current_state != CharState.GRAB:
		current_state = CharState.MOVE
	elif current_state != CharState.GRAB:
		current_state = CharState.IDLE
	play_anim()
	if input != Vector2.ZERO:
		particle_trail.amount_ratio = 1.0
	else:
		particle_trail.amount_ratio = 0.0
	
func black_hole_slow(bh_distance: float):
	if bh_distance <= 16500:
		Engine.time_scale = 1.0/60.0
	elif bh_distance <= 32000:
		Engine.time_scale = (bh_distance - 16000) / 32000
	elif bh_distance <= 64000:
		Engine.time_scale = bh_distance / 64000
	else:
		Engine.time_scale = 1.0
		
func black_hole_zoom(bh_distance: float, delta: float):
	if bh_distance <= 25000:
		cam.zoom = cam.zoom.lerp(Vector2(0.78125, 0.78125), delta * zoom_speed)
	elif bh_distance <= 64000:
		cam.zoom = cam.zoom.lerp(Vector2(bh_distance/32000, bh_distance/32000), delta * zoom_speed)
	else:
		cam.zoom = cam.zoom.lerp(Vector2(2, 2), delta * zoom_speed) #reset to 2, 2
	
func play_anim():
	var anim_name = ""
	match current_state:
		CharState.IDLE:
			anim_name = "idle"
		CharState.MOVE:
			anim_name = "move"
		CharState.GRAB:
			anim_name = "grab"
	animated_sprite.play(anim_name)
