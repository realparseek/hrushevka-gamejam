extends Node
class_name DoorLight

@export var door: StaticBody3D
@export var light_source: LightSource
@export var working_color: Color
@export var locked_color: Color

var DOOR: Door = null

func _ready() -> void:
	for c in door.get_children():
		if c is Door:
			DOOR = c
			break
	light_source.light.light_color = locked_color if DOOR.locked else working_color

func _process(_delta: float) -> void:
	if DOOR.locked and light_source.COLOR != locked_color:
		light_source.COLOR = locked_color
	if not DOOR.locked and light_source.COLOR != working_color:
		light_source.COLOR = working_color
