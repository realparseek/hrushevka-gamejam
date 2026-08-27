extends Interaction
class_name DoorClose

@export var door: Door
@export var door_open: Interaction

func interacte() -> void:
	if not door: return
	if not door.close(): return
	if door_open: door_open.available = true
	available = false
