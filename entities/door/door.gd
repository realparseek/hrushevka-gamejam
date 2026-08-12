extends Node
class_name Door

@export var animation_player: AnimationPlayer

var OPENED: bool = false

func open() -> void:
	if animation_player:
		if animation_player.is_playing(): return
		animation_player.play("open")
	OPENED = true

func close() -> void:
	if animation_player:
		if animation_player.is_playing(): return
		animation_player.play("open")
	OPENED = false
