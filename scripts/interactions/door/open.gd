extends Interaction

func _ready() -> void:
	debug_name = "Открыть"

func interacte() -> void:
	$"../../StateMachine/Opened".Transitioned.emit("opened", $"../../StateMachine".current_state)
