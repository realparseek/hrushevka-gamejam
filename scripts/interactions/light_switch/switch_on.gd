extends Interaction

@export var turn_on_state: State

func interacte() -> void:
	turn_on_state.Transitioned.emit("turnedon", turn_on_state.get_parent().current_state)
