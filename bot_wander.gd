extends CharacterBody2D

@export var bounds_min := Vector2(-4.0, -2.0)
@export var bounds_max := Vector2(36.0, 4.0)
@export var speed: float = 1.0
@export var rotation_speed: float = 1.0
var target_pos: Vector2 = Vector2(0.0, 0.0)
var can_retarget: bool = false
@export var position_tolerance: float = 2.0
@onready var reposition_timer: Timer = $RepositionTimer
var current_state: BotState = BotState.IDLE
@onready var animated_sprite: AnimatedSprite2D = $BotSprite

enum BotState {
	IDLE,
	MOVE,
	GRAB
}

func _process(_delta: float) -> void:
	play_anim()
	
func _physics_process(delta: float) -> void:
	if can_retarget:
		target_pos = Vector2(randf_range(bounds_min.x, bounds_max.x), randf_range(bounds_min.y, bounds_max.y))
		can_retarget = false
	if position.distance_to(target_pos) > position_tolerance:
		current_state = BotState.MOVE
		position = lerp(position, target_pos, delta * speed)
	else:
		current_state = BotState.IDLE
		if reposition_timer.time_left <= 0:
			reposition_timer.start()
		position = lerp(position, target_pos, delta * speed)
	move_and_slide()
	play_anim()

func play_anim():
	var anim_name = ""
	match current_state:
		BotState.IDLE:
			anim_name = "idle"
		BotState.MOVE:
			anim_name = "move"
		BotState.GRAB:
			anim_name = "grab"
	animated_sprite.play(anim_name)

func _on_reposition_timer_timeout() -> void:
	can_retarget = true
