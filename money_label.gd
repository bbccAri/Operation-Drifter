extends RichTextLabel
class_name MoneyLabel

@export var start_tags: String = "[center][wave amp=8.0 freq=4.0 connected=1][pulse freq=0.5 color=#ffffff40 ease=-2.0][b]"
@export var end_tags: String = "[/b][/pulse][/wave][/center]"

func update_money_label(new_money: int):
	text = start_tags + "$" + str(new_money) + end_tags
