extends Node

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE and event.pressed:
			get_tree().quit()
