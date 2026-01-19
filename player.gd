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
var debris_in_range: Array = []
var target_pickup_object: Node2D
@onready var grabbed_position: Marker2D = $GrabbedPosition
var grabbed_object: Node2D

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
			pickup()
		else:
			drop_object()
	if input != Vector2.ZERO and current_state != CharState.GRAB:
		current_state = CharState.MOVE
	elif current_state != CharState.GRAB:
		current_state = CharState.IDLE
	play_anim()
	if input != Vector2.ZERO:
		particle_trail.amount_ratio = 1.0
	else:
		particle_trail.amount_ratio = 0.0
	#print(global_position)
	
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
		cam.zoom = cam.zoom.lerp(Vector2(2, 2), delta * zoom_speed)
	
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

func pickup() -> void:
	if debris_in_range.size() > 0:
		target_pickup_object = debris_in_range[0]
		for item in debris_in_range:
			if global_position.distance_squared_to(item.global_position) < global_position.distance_squared_to(target_pickup_object.global_position):
				target_pickup_object = item
		pickup_object(target_pickup_object)
	
func pickup_object(body: Debris) -> void:
	grabbed_position.global_position = body.global_position
	body.reparent(grabbed_position)
	if body is Debris:
		body.grab()
	grabbed_object = body
	#TODO: figure out which direction the grab is in and display correct grab sprite
	current_state = CharState.GRAB
	
func drop_object() -> void:
	grabbed_object.reparent(get_tree().current_scene)
	if grabbed_object is Debris:
		grabbed_object.ungrab()
	current_state = CharState.IDLE

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Debris:
		debris_in_range.append(body)
		if target_pickup_object == null:
			target_pickup_object = body

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body is Debris:
		debris_in_range.erase(body)
		if debris_in_range.is_empty():
			target_pickup_object = null
