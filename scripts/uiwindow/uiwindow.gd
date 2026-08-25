extends Node
class_name UIWindow

@export var rect: NinePatchRect
@export var resize_bounds: Control
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
var WINSTARTPOS: Vector2 = Vector2.ZERO
var WINSTARTSIZE: Vector2 = Vector2.ZERO
var MOUSESTARTPOS: Vector2 = Vector2.ZERO

func _ready() -> void:
	title = window_title
	message = window_message

func _input(event: InputEvent) -> void:
	if not rect: return
	
	if event is InputEventMouseButton:
		if event.pressed:
			var mpos: Vector2 = event.global_position
			var in_window: bool = rect.get_rect().has_point(mpos)
			var real_resize_area = Rect2(resize_bounds.global_position, resize_bounds.size)
			var is_resize_area: bool = real_resize_area.has_point(mpos)
			if is_resize_area: 
				WINSTARTSIZE = rect.size
				MOUSESTARTPOS = event.global_position
				RESIZING = true
			elif in_window: 
				WINSTARTPOS = rect.global_position
				MOUSESTARTPOS = event.global_position
				DRAGGING = true
		else:
			DRAGGING = false
			RESIZING = false
	
	if event is InputEventMouseMotion:
		var mpos: Vector2 = event.global_position
		if DRAGGING: 
			rect.global_position = WINSTARTPOS + (event.global_position-MOUSESTARTPOS)
		if RESIZING: 
			rect.size = rect.get_global_transform().affine_inverse() * mpos
	
	var rwsize = Vector2(get_viewport().size)
	rect.global_position.x = clamp(rect.global_position.x, -25, rwsize.x-25)
	rect.global_position.y = clamp(rect.global_position.y, -25, rwsize.y-25)
