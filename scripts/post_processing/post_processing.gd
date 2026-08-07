extends Node
class_name PostProccessing

@export var camera: Camera3D

func set_accum_blur(value: float) -> void:
	if not camera: return
	for ce in camera.compositor.compositor_effects:
		if ce is not AccumulativeBlurEffect: continue
		ce.alpha = clamp(value, 0, 1)
		break
