extends Interaction
class_name DoorClose

@export var animation_player: AnimationPlayer
@export var door_open: Interaction

func interacte() -> void:
	if not animation_player: return
	animation_player.play("close")
	available = false
	door_open.available = true
