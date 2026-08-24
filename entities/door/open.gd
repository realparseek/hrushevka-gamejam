extends Interaction
class_name DoorOpen

@export var animation_player: AnimationPlayer
@export var door_close: Interaction

func interacte() -> void:
	if not animation_player: return
	animation_player.play("open")
	available = false
	door_close.available = true
