extends UIWindow
class_name FPSWindow

func _process(_delta: float) -> void:
	message = str(int(Engine.get_frames_per_second()))
