extends Node
class_name PauseMenu

@export var menu: ColorRect
@export var resume_button: Button
@export var exit_button: Button

var PAUSED: bool = true

func _ready() -> void:
	if resume_button: resume_button.connect("pressed", _on_resume_btn_press)
	if exit_button: exit_button.connect("pressed", _on_exit_btn_press)
	pause()

func pause() -> void:
	var bid = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bid, true)
	Engine.time_scale = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu.visible = true
	PAUSED = true

func unpause() -> void:
	var bid = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bid, false)
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.visible = false
	PAUSED = false

func _on_resume_btn_press() -> void:
	unpause()

func _on_exit_btn_press() -> void:
	get_tree().quit()
