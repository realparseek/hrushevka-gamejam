extends Node
class_name UIWindow

@export var rect: NinePatchRect

var DRAGGING: bool = false
var WSTARTPOS: Vector2 = Vector2.ZERO
var MSTARTPOS: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var wrect = Rect2(rect.global_position, rect.size)
			if wrect.has_point(event.position):
				DRAGGING = true
				WSTARTPOS = wrect.position
				MSTARTPOS = event.position
		else:
			DRAGGING = false
	
	if event is InputEventMouseMotion and DRAGGING:
		rect.global_position = WSTARTPOS + event.position - MSTARTPOS
		
	var rwsize = get_window().size
	rect.global_position.x = clamp(rect.global_position.x, -25, rwsize.x-25)
	rect.global_position.y = clamp(rect.global_position.y, -25, rwsize.y-25)
