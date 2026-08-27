extends Node
class_name Door

@export var animation_player: AnimationPlayer
@export var locked: bool = true

var OPENED: bool = false

func open() -> bool:
	if locked:
		animation_player.play("locked")
		return false
	if not animation_player: return false
	if animation_player.is_playing(): return false
	
	animation_player.play("open")
	OPENED = true
	return true

func close() -> bool:
	if locked:
		animation_player.play("locked")
		return false
	if not animation_player: return false
	if animation_player.is_playing(): return false
	
	animation_player.play("close")
	OPENED = false
	return true
