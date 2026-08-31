extends Interaction
class_name DoorOpen

@export var door: Door
@export var door_close: Interaction

func interacte(_player: CharacterBody3D) -> void:
	if not door: return
	if not door.open(): return
	if door_close: door_close.available = true
	available = false
