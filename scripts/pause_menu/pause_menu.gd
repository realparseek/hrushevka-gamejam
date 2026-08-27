extends Node
class_name PauseMenu

@export var menu: ColorRect
@export var resume_button: Button
@export var exit_button: Button
@export var ambient: AudioStreamPlayer

var PAUSED: bool = false
var AMBIENTPOS: float = 0.0

func _ready() -> void:
	if resume_button: resume_button.connect("pressed", _on_resume_btn_press)
	if exit_button: exit_button.connect("pressed", _on_exit_btn_press)
	menu.visible = PAUSED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if PAUSED else Input.MOUSE_MODE_CAPTURED)
	#pause()

func pause() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu.visible = true
	
	if ambient:
		ambient.play(AMBIENTPOS)
		PAUSED = true

func unpause() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.visible = false
	AMBIENTPOS = ambient.get_playback_position()
	PAUSED = false
	
	if ambient: ambient.stop()

func _on_resume_btn_press() -> void:
	unpause()

func _on_exit_btn_press() -> void:
	get_tree().quit()
