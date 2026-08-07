extends Node
class_name FPSCounter

@export var fps_label: Label

func _process(_delta: float) -> void:
	if fps_label:
		fps_label.text = str(int(Engine.get_frames_per_second()))
