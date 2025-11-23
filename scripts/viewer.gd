extends Control

@onready var is_viewing: bool = false

func _physics_process(delta: float) -> void:
	_handle_viewing(delta)

func _handle_viewing(delta: float) -> void:
	$background.color.a = lerpf($background.color.a, 0.7 * float(is_viewing), delta*5)

func enter() -> void:
	is_viewing = true

func exit() -> void:
	is_viewing = false
