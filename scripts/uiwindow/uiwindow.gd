extends Node
class_name UIWindow

@export var rect: NinePatchRect
@export var window_title: String
@export_multiline var window_message: String

var title: String:
	get: return rect.get_node("title").text
	set(value): rect.get_node("title").text = value
var message: String:
	get: return rect.get_node("message").text
	set(value): rect.get_node("message").text = value

var DRAGGING: bool = false
var RESIZING: bool = false
var WSTARTPOS: Vector2 = Vector2.ZERO
var MSTARTPOS: Vector2 = Vector2.ZERO
var WSTARTSIZE: Vector2 = Vector2.ZERO

func _ready() -> void:
	title = window_title
	message = window_message

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var wrect = Rect2(rect.global_position, rect.size)
			var rrect = Rect2(wrect.position+wrect.size-Vector2(25,25), Vector2(25,25))
			if rrect.has_point(event.position):
				RESIZING = true
				WSTARTSIZE = wrect.size
				MSTARTPOS = event.position
			elif wrect.has_point(event.position):
				DRAGGING = true
				WSTARTPOS = wrect.position
				MSTARTPOS = event.position
				Input.set_default_cursor_shape(Input.CURSOR_BDIAGSIZE)
		else:
			DRAGGING = false
			RESIZING = false
	
	if event is InputEventMouseMotion:
		if DRAGGING:
			rect.global_position = WSTARTPOS + event.position - MSTARTPOS
		elif RESIZING:
			rect.size = WSTARTSIZE + event.position - MSTARTPOS
		
	var rwsize = get_window().size
	rect.global_position.x = clamp(rect.global_position.x, -25, rwsize.x-25)
	rect.global_position.y = clamp(rect.global_position.y, -25, rwsize.y-25)
