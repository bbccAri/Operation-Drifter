extends CharacterBody2D

enum CharState {
	IDLE,
	MOVE,
	GRAB
}

@export var speed = 1000
@export var rotation_speed = 100
@export var acceleration = 5
var current_state: CharState = CharState.IDLE
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

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
	move_and_slide()
	
func _process(_delta: float) -> void:
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
