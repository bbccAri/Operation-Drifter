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
@export var gravity_resistance_amount: float = 0.25
@export var gravity_resistance_max_level: int = 3
var gravity_resistance_level: int = 0
@export var gravity_resistance_price: int = 3000
@onready var particle_trail: GPUParticles2D = $TrailParticles
var debris_in_range: Array[Debris] = []
var target_pickup_object: Node2D
@onready var grabbed_position: Marker2D = $GrabbedPosition
var grabbed_object: Debris
var money: int = 0 : set = _set_money
var cargo_capacity: int = 50
var cargo_carrying: int = 0
var cargo_value: int = 0
var warning_distance: float = 56000.0
var health: int = 2 : set = _set_health
@export var max_health: int = 2 : set = _set_max_health
@export var health_bar: HealthBar
@export var o2_bar: O2Bar
var near_shop: bool = false
var in_safe_zone: bool = false
var in_dialogue: bool = false
var suffocating: bool = false
@export var money_label: MoneyLabel
@export var damage_cooldown: float = 5.0
var iframes: float = 0.0
@export var HUD_image: NinePatchRect
@export var damage_hud_fade_speed: float = 5.0
var dead: bool = false
@export var death_screen: Control
var scanning: bool = false

var suit_resilience_level: int = 0
@export var suit_resilience_max_level: int = 5
@export var suit_resilience_price: int = 4000
var suit_thruster_power_level: int = 0
@export var suit_thruster_power_max_level: int = 5
@export var suit_thruster_power_price: int = 2000
@export var suit_thruster_power_amount: float = 0.2
var o2_left: float = 20.0
var o2_tank_size_level: int = 2 : set = _set_o2_tank_size_level
@export var o2_tank_size_max_level: int = 10
@export var o2_tank_size_price: int = 1000
@export var o2_tank_size_amount: float = 10.0
@export var repair_price: int = 1000
var cargo_space_level: int = 2
@export var cargo_space_max_level: int = 10
@export var cargo_space_price: int = 1500
@export var cargo_space_amount: int = 25

var in_ship: bool = false
@export var ship_zoom_multiplier: float = 0.8

var zoom_modifier: float = 1.0
@export var zoom_extents_min: float = 0.5
@export var zoom_extents_max: float = 2.0
@export var zoom_scroll_amount: float = 0.1

@export var zoom_debug: bool = false
@export var zoom_debug_scale: float = 0.005

func _ready() -> void:
	DialogicToPlayer.player = self
	Dialogic.timeline_started.connect(on_dialogue_start)
	Dialogic.timeline_ended.connect(on_dialogue_end)
	health_bar.init_health()
	o2_bar.init_o2()
	health = max_health
	cargo_capacity = cargo_space_level * cargo_space_amount

func _set_health(new_health: int):
	var prev_health = health
	health = clamp(new_health, 0, max_health)
	health_bar.update_health(new_health, prev_health)

func _set_max_health(new_max_health: int):
	max_health = new_max_health
	health_bar.update_max_health(max_health)

func _set_o2_tank_size_level(new_size: int):
	o2_tank_size_level = new_size
	o2_bar.update_max_o2(o2_tank_size_level * o2_tank_size_amount)

func _set_money(new_money: int):
	money = new_money
	if money_label != null:
		money_label.update_money_label(new_money)

func get_movement_input():
	if dead:
		return Vector2.ZERO
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
	#if in_ship: 
		#o2_left += 1.0 * delta
		#return
	var direction = get_movement_input()
	if in_dialogue:
		direction = Vector2.ZERO
	rotation_degrees += direction.x * rotation_speed * delta
	velocity = lerp(velocity, Vector2(0, direction.normalized().y).rotated(rotation) * (speed * (1 + suit_thruster_power_level * suit_thruster_power_amount)), delta * acceleration)
	velocity += get_gravity() * (1.0 - gravity_resistance_level * gravity_resistance_amount)
	move_and_slide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().quit() #TEMP TODO: PAUSE MENU!!!
	if suffocating:
		take_damage(1)
	var bh_distance = global_position.distance_to(black_hole.global_position)
	black_hole_slow(bh_distance)
	black_hole_zoom(bh_distance, delta, zoom_modifier)
	var input = get_movement_input()
	if in_dialogue:
		input = Vector2.ZERO
	if Input.is_action_just_pressed("Interact") and !in_ship and !in_dialogue and !dead:
		if current_state != CharState.GRAB:
			pickup()
		else:
			drop_object()
	if Input.is_action_just_pressed("Scan"):
		scanning = !scanning
	if input != Vector2.ZERO and current_state != CharState.GRAB and !dead:
		current_state = CharState.MOVE
	elif current_state != CharState.GRAB:
		current_state = CharState.IDLE
	play_anim()
	var max_o2: float = o2_tank_size_amount * o2_tank_size_level
	var prev_o2: float = o2_left
	if !in_ship and !dead:
		particle_trail.amount_ratio = max(abs(input.x), abs(input.y))
		if o2_left > 0.0 and !in_safe_zone and !in_dialogue:
			o2_left -= delta
			if o2_left <= 0:
				o2_left = 0.0
				suffocating = true
		elif in_safe_zone:
			o2_left += delta
			if o2_left > max_o2:
				o2_left = max_o2
			suffocating = false
	else:
		particle_trail.amount_ratio = 0.0
		if o2_left < max_o2 and !dead:
			o2_left += delta
			if o2_left > max_o2:
				o2_left = max_o2
		suffocating = false
	update_o2_visuals(o2_left, prev_o2)
	#print(global_position)
	
	if health <= roundi(max_health / 2.0):
		HUD_image.self_modulate = lerp(HUD_image.self_modulate, Color(1.0, 0.0, 0.0, 129.0/255.0), delta * damage_hud_fade_speed)
	else:
		HUD_image.self_modulate = lerp(HUD_image.self_modulate, Color(1.0, 1.0, 1.0, 129.0/255.0), delta * damage_hud_fade_speed)
	
	if iframes > 0.0:
		iframes -= delta
	
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
	if grabbed_object == null:
		current_state = CharState.IDLE
		return
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

func upgrade_gravity_resistance():
	if gravity_resistance_level < gravity_resistance_max_level:
		gravity_resistance_level += 1

func upgrade_suit_resilience():
	if suit_resilience_level < suit_resilience_max_level:
		max_health += 1
		health += 1
		
func upgrade_thruster_power():
	if suit_thruster_power_level < suit_thruster_power_max_level:
		suit_thruster_power_level += 1
		
func upgrade_o2_tank_size():
	if o2_tank_size_level < o2_tank_size_max_level:
		o2_tank_size_level += 1

func update_o2_visuals(new_o2: float, prev_o2: float):
	o2_bar.update_o2(new_o2, prev_o2)

func take_damage(amount: int):
	if iframes > 0.0:
		return
	health -= amount
	if health <= 0:
		die()
	elif health <= roundi(max_health / 2.0):
		pass #enable damaged effect on HUD
	iframes = damage_cooldown
	
func repair_suit():
	health = max_health
	#disable damaged effect on HUD

func upgrade_cargo_size():
	if cargo_space_level < cargo_space_max_level:
		cargo_space_level += 1
		cargo_capacity = cargo_space_level * cargo_space_amount

func die():
	#get_tree().quit() #TEMP!!! TODO: actual death
	dead = true
	death_screen.visible = true

func on_dialogue_start():
	in_dialogue = true

func on_dialogue_end():
	in_dialogue = false
