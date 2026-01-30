extends Node2D

@export var target: Node2D
@onready var arrow: Node2D = $Arrow
@onready var label_follow_pos: Node2D = $Arrow/Sprite2D/LabelLocation
@onready var label: RichTextLabel = $RichTextLabel
@export var player: Player
@onready var anim: AnimationPlayer = $Arrow/AnimationPlayer
@export var label_text: String = ""
@export var text_tags_start: String = "[center][wave amp=8.0 freq=4.0 connected=1][pulse freq=0.5 color=#ffffff80 ease=-2.0]"
@export var text_tags_end: String = "[/pulse][/wave][/center]"
@export var icon_type: IconType = IconType.None
@onready var icons: Node2D = $Icons
@onready var bh_icon: Node2D = $"Icons/BH icon"
@onready var shop_icon: Node2D = $"Icons/Shop icon"
@onready var ship_icon: Node2D = $"Icons/Ship icon"
@onready var warning_icon: AnimatedSprite2D = $"Icons/BH icon/SpriteWarning"
@export var close_enough_distance: float = 256.0

enum IconType {
	None,
	BlackHole,
	Shop,
	Ship
}

enum DisplayMode {
	TextDist,
	IconDist,
	DistOnly,
	TextOnly,
	IconOnly,
	None
}

@export var display_mode: DisplayMode = DisplayMode.IconDist

func _ready() -> void:
	if target == null:
		target = player.black_hole
	if display_mode != DisplayMode.IconOnly and display_mode != DisplayMode.None:
		label.text = text_tags_start + label_text if (display_mode == DisplayMode.TextDist or display_mode == DisplayMode.TextOnly) else "" + ("\n" + get_distance_text(global_position.distance_to(target.global_position))) if (display_mode == DisplayMode.TextDist or display_mode == DisplayMode.IconDist or display_mode == DisplayMode.DistOnly) else "" + text_tags_end
	if display_mode == DisplayMode.IconDist or display_mode == DisplayMode.IconOnly:
		if icon_type == IconType.BlackHole:
			bh_icon.visible = true
			warning_icon.play("default")
		elif icon_type == IconType.Shop:
			shop_icon.visible = true
		elif icon_type == IconType.Ship:
			ship_icon.visible = true
	anim.play("arrow_bob")

func _process(_delta: float) -> void:
	if (target == null or target.is_queued_for_deletion()):
		target = null
		return
	var distance = global_position.distance_to(target.global_position)
	if (player.scanning and distance > close_enough_distance) or (icon_type == IconType.BlackHole and distance <= player.warning_distance):
		visible = true
	else:
		visible = false
	if player != null:
		global_position = player.global_position
	if target != null:
		arrow.global_rotation = get_angle_to(target.global_position) + PI/2
		label.global_position = label_follow_pos.global_position + Vector2(-32, -32)
		if display_mode != DisplayMode.IconOnly and display_mode != DisplayMode.TextOnly and display_mode != DisplayMode.None:
			label.text = text_tags_start + label_text if (display_mode == DisplayMode.TextDist or display_mode == DisplayMode.TextOnly) else "" + ("\n" + get_distance_text(distance)) if (display_mode == DisplayMode.TextDist or display_mode == DisplayMode.IconDist or display_mode == DisplayMode.DistOnly) else "" + text_tags_end
		icons.global_position = label_follow_pos.global_position + Vector2(0, -16)
	if distance <= player.warning_distance and icon_type == IconType.BlackHole:
		warning_icon.visible = true
		warning_icon.speed_scale = pow(player.warning_distance, 2) / pow(distance, 2)
	else:
		warning_icon.visible = false

func get_distance_text(distance: float) -> String:
	return str(int(round(distance)))
