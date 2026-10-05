extends Node
class_name Train

func _ready() -> void:
	$"../anim_player".play("riding")

#func _process(_delta: float) -> void:
	#if not $"../anim_player".is_playing():
		#$"../anim_player".play("riding")
