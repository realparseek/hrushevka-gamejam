extends Node
class_name Door

@export var locked: bool = true
@export var animation_player: AnimationPlayer
@export var interactable: Interactable

var OPENED: bool = false

func open() -> bool:
	if locked:
		animation_player.play("locked")
		interactable.MESSAGE = "Закрыто."
		interactable.MESSAGETIME = 5.0
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
