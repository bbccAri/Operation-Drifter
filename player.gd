extends CharacterBody2D
class_name Player

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
var debris_in_range: Array[Debris] = []
var target_pickup_object: Node2D
@onready var grabbed_position: Marker2D = $GrabbedPosition
var grabbed_object: Debris
var money: int = 0
var cargo_capacity: int = 50
var cargo_carrying: int = 0
var cargo_value: int = 0
var warning_distance: float = 56000.0

var in_ship: bool = false
@export var ship_zoom_multiplier: float = 0.8

var zoom_modifier: float = 1.0
@export var zoom_extents_min: float = 0.5
@export var zoom_extents_max: float = 2.0
@export var zoom_scroll_amount: float = 0.1

@export var zoom_debug: bool = false
@export var zoom_debug_scale: float = 0.005

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

func get_zoom_input():
	var input: float = 0.0
	if Input.is_action_pressed("Zoom_In") or Input.is_action_just_pressed("Zoom_In_Scroll"):
		input += 1.0
	if Input.is_action_pressed("Zoom_Out") or Input.is_action_just_pressed("Zoom_Out_Scroll"):
		input -= 1.0
	return input

func _physics_process(delta):
	if in_ship: return
	var direction = get_movement_input()
	rotation_degrees += direction.x * rotation_speed * delta
	velocity = lerp(velocity, Vector2(0, direction.normalized().y).rotated(rotation) * speed, delta * acceleration)
	velocity += get_gravity() * gravity_resistance
	move_and_slide()
	
func _process(delta: float) -> void:
	var bh_distance = global_position.distance_to(black_hole.global_position)
	black_hole_slow(bh_distance)
	black_hole_zoom(bh_distance, delta, zoom_modifier)
	var input = get_movement_input()
	if Input.is_action_just_pressed("Interact") and !in_ship:
		if current_state != CharState.GRAB:
			pickup()
		else:
			drop_object()
	if input != Vector2.ZERO and current_state != CharState.GRAB:
		current_state = CharState.MOVE
	elif current_state != CharState.GRAB:
		current_state = CharState.IDLE
	play_anim()
	if !in_ship:
		particle_trail.amount_ratio = max(abs(input.x), abs(input.y))
	else:
		particle_trail.amount_ratio = 0.0
	#print(global_position)
	
	var zoom_input = get_zoom_input()
	if zoom_input > 0 and (zoom_modifier <= zoom_extents_max or zoom_debug):
		zoom_modifier += zoom_scroll_amount * zoom_input * zoom_modifier
	elif zoom_input < 0 and (zoom_modifier >= zoom_extents_min or zoom_debug):
		zoom_modifier += zoom_scroll_amount * zoom_input * zoom_modifier
	if !zoom_debug:
		zoom_modifier = clampf(zoom_modifier, zoom_extents_min, zoom_extents_max)
	
func black_hole_slow(bh_distance: float):
	if bh_distance <= 16500:
		Engine.time_scale = 1.0/60.0
	elif bh_distance <= 32000:
		Engine.time_scale = (bh_distance - 16000) / 32000
	elif bh_distance <= 64000:
		Engine.time_scale = bh_distance / 64000
	else:
		Engine.time_scale = 1.0
		
func black_hole_zoom(bh_distance: float, delta: float, modifier: float = 1.0):
	if zoom_debug:
		cam.zoom = Vector2(zoom_debug_scale, zoom_debug_scale) * modifier
	else:
		if bh_distance <= 25000:
			cam.zoom = cam.zoom.lerp(Vector2(0.78125, 0.78125) * modifier * (ship_zoom_multiplier if in_ship else 1.0), delta * zoom_speed)
		elif bh_distance <= 64000:
			cam.zoom = cam.zoom.lerp(Vector2(bh_distance/32000, bh_distance/32000) * modifier * (ship_zoom_multiplier if in_ship else 1.0), delta * zoom_speed)
		else:
			cam.zoom = cam.zoom.lerp(Vector2(2, 2) * modifier * (ship_zoom_multiplier if in_ship else 1.0), delta * zoom_speed)

func enter_ship():
	visible = false
	in_ship = true

func exit_ship():
	in_ship = false
	visible = true

func play_anim():
	if in_ship: return
	var anim_name = ""
	match current_state:
		CharState.IDLE:
			anim_name = "idle"
		CharState.MOVE:
			if abs(get_movement_input().y) >= 0.5:
				anim_name = "move"
			else:
				anim_name = "move_light"
		CharState.GRAB:
			if grabbed_position.position.x <= 0 and abs(grabbed_position.position.x) > abs(grabbed_position.position.y):
				anim_name = "grab_left"
			elif grabbed_position.position.x > 0 and abs(grabbed_position.position.x) > abs(grabbed_position.position.y):
				anim_name = "grab_right"
			elif grabbed_position.position.y >= 0 and abs(grabbed_position.position.x) <= abs(grabbed_position.position.y):
				anim_name = "grab_down"
			elif grabbed_position.position.y < 0 and abs(grabbed_position.position.x) <= abs(grabbed_position.position.y):
				anim_name = "grab_up"
			else:
				anim_name = "grab_down"
				push_warning("unexpected grab position!")
	animated_sprite.play(anim_name)

func pickup() -> void:
	if debris_in_range.size() > 0:
		target_pickup_object = debris_in_range[0]
		for item: Debris in debris_in_range:
			if global_position.distance_squared_to(item.global_position) < global_position.distance_squared_to(target_pickup_object.global_position):
				if !item.exploding:
					target_pickup_object = item
		pickup_object(target_pickup_object)
	
func pickup_object(body: Debris) -> void:
	grabbed_position.global_position = body.global_position
	body.reparent(grabbed_position)
	body.grab()
	grabbed_object = body
	current_state = CharState.GRAB
	add_collision_exception_with(body)

func store_object():
	remove_collision_exception_with(grabbed_object)
	cargo_carrying += grabbed_object.cargo_size
	cargo_value += grabbed_object.value
	grabbed_object.store()
	grabbed_object = null
	current_state = CharState.IDLE

func drop_object() -> void:
	if is_instance_valid(grabbed_object):
		grabbed_object.call_deferred("reparent", get_tree().current_scene)
		if grabbed_object is Debris:
			grabbed_object.ungrab()
		remove_collision_exception_with(grabbed_object)
	grabbed_object = null
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
