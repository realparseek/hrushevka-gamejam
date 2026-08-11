extends Node
class_name Door

@export var animation_player: AnimationPlayer

var OPENED: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("item_interacte"):
		open()

func open() -> void:
	if animation_player:
		if animation_player.is_playing(): return
		animation_player.play("open")
	OPENED = true

func close() -> void:
	OPENED = false