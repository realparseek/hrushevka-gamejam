extends Node
class_name Draggable

@export var drag_value: float
@export var hoverable: Hoverable

var IS_DRAGGING: bool = false
var WAS_HOVERED: bool = false

func _process(_delta: float) -> void:
	if not hoverable: return

func drag(drag_amount: float) -> void:
	if not IS_DRAGGING: return
	drag_value += drag_amount
	drag_value = clamp(drag_value, 0.0, 1.0)

func start_dragging() -> void:
	if IS_DRAGGING: return
	IS_DRAGGING = true

func stop_dragging() -> void:
	if not IS_DRAGGING: return
	IS_DRAGGING = false
