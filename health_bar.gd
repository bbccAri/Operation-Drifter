extends ProgressBar
class_name HealthBar

@export var player: Player
@onready var timer: Timer
@onready var damage_bar: ProgressBar
@onready var sprite_over: Control 
@onready var sprite_under: Control

func _ready():
	init_health()

func init_health():
	timer = $DamageCatchup
	damage_bar = $DamageBar
	sprite_under = $"../MarginContainer/Control/O2Under"
	sprite_over = $"../MarginContainer/Control/O2Over"
	update_max_health(player.max_health)
	value = player.health
	damage_bar.value = player.health
	
func update_health(new_health: int, prev_health: int):
	value = new_health
	if new_health < prev_health:
		timer.start()
	else:
		damage_bar.value = new_health

func update_max_health(new_max_health: int):
	max_value = new_max_health
	damage_bar.max_value = new_max_health
	custom_minimum_size.y = 76 * new_max_health
	sprite_under.size.y = 160 + 76 * new_max_health
	#sprite_under.positon.y = -80 - 38 * new_max_health
	sprite_over.size.y = 160 + 76 * new_max_health
	#sprite_over.positon.y = -80 - 38 * new_max_health

func _on_damage_catchup_timeout() -> void:
	damage_bar.value = player.health
