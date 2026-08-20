extends Node
class_name PauseMenu

@export var menu: ColorRect

var PAUSED: bool = true

func _ready() -> void:
	pause()

func pause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu.visible = true
	PAUSED = true

func unpause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.visible = false
	PAUSED = false
