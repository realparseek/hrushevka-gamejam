extends Node
class_name Messenger

@export var label: Label
@export var message: String
@export var timer: float

func _ready() -> void:
	if not label: return
	label.text = message

func _process(delta: float) -> void:
	if timer < 1.0:
		label.label_settings.font_color.a = timer
	
	timer = max(timer-delta, 0.0)

func push_message(msg: String, time: float = 5.0):
	label.label_settings.font_color.a = 1.0
	label.text = msg
	message = msg
	timer = time
