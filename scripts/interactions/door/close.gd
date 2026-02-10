extends Interaction

func _ready() -> void:
	debug_name = "ЗАКРЫТЬ"

func interacte() -> void:
	$"../../StateMachine/Opened".Transitioned.emit("closed", $"../../StateMachine".current_state)
