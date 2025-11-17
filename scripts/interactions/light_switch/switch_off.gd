extends Interaction

@export var turn_off_state: State

func _ready() -> void:
	debug_name = "Выключить"

func interacte() -> void:
	turn_off_state.Transitioned.emit("turnedoff", turn_off_state.get_parent().current_state)
