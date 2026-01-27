extends ProgressBar
class_name O2Bar

@export var player: Player
@onready var timer: Timer
@onready var drain_bar: ProgressBar
@onready var sprite_over: Control 
@onready var sprite_under: Control
var do_catchup: bool = false
@export var catchup_speed: float = 1.0

func _ready():
	init_o2()

func _process(delta: float) -> void:
	if do_catchup:
		drain_bar.value = lerp(drain_bar.value, player.o2_left, catchup_speed * delta)

func init_o2():
	timer = $DrainCatchup
	drain_bar = $DrainBar
	sprite_under = $"../MarginContainer/Control/O2Under"
	sprite_over = $"../MarginContainer/Control/O2Over"
	update_max_o2(player.o2_tank_size_level * player.o2_tank_size_amount)
	value = player.o2_left
	drain_bar.value = player.o2_left
	
func update_o2(new_o2: float, prev_o2: float):
	if new_o2 != prev_o2 and (drain_bar.value - new_o2 < 3.0 or new_o2 == 0):
		do_catchup = false
	else:
		do_catchup = true
	value = new_o2
	if new_o2 < prev_o2 and timer.time_left == 0:
		timer.start()

func update_max_o2(new_max_o2: float):
	max_value = new_max_o2
	drain_bar.max_value = new_max_o2
	custom_minimum_size.y = 76 * new_max_o2 / 10.0
	sprite_under.size.y = 160 + 76 * new_max_o2 / 10.0
	#sprite_under.positon.y = -80 - 38 * new_max_health
	sprite_over.size.y = 160 + 76 * new_max_o2 / 10.0
	#sprite_over.positon.y = -80 - 38 * new_max_health

func _on_damage_catchup_timeout() -> void:
	do_catchup = true
	drain_bar.value = player.health
