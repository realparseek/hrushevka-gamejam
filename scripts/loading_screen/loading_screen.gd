extends Node
class_name LoadingScreen

@export var animation_player: AnimationPlayer

func show() -> void:
	if not animation_player: return
	animation_player.play("show")

func hide() -> void:
	if not animation_player: return
	animation_player.play("hide")

func is_playing() -> bool:
	if not animation_player: return false
	return animation_player.is_playing()
