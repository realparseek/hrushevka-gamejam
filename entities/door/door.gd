extends Node
class_name Door

@export var locked: bool = true
@export var animation_player: AnimationPlayer
@export var interactable: Interactable

var OPENED: bool = false
var _animated_node: Node3D = null
var _closed_transform: Transform3D = Transform3D.IDENTITY


func _ready() -> void:
	if not animation_player: return
	var anim := animation_player.get_animation("RESET")
	if not anim or anim.get_track_count() == 0: return
	var path := anim.track_get_path(0)
	var node := animation_player.get_node_or_null(path) as Node3D
	if node == null:
		node = animation_player.get_parent().get_node_or_null(path) as Node3D
	if node == null: return
	_animated_node = node
	_closed_transform = node.transform

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


func set_visual_state(opened: bool) -> void:
	OPENED = opened
	if not animation_player: return

	if opened:
		var anim := animation_player.get_animation("open")
		if not anim: return
		animation_player.stop()
		animation_player.play("open")
		animation_player.seek(anim.length)
	else:
		animation_player.stop()
		if _animated_node:
			_animated_node.transform = _closed_transform


func sync_interactions() -> void:
	if not interactable: return
	for inter in interactable.interactions.values():
		if inter is DoorOpen:
			inter.available = not OPENED
		elif inter is DoorClose:
			inter.available = OPENED
