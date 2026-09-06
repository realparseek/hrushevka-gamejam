extends Node
class_name LightSource

@export var light: Light3D

var WORKING: bool = true

var COLOR: 
	get: return light.light_color if light else Color.BLACK
	set(value): 
		if light: light.light_color = value

func _ready() -> void:
	if WORKING: turn_on()
	else: turn_off()

func turn_on() -> void:
	if light: light.visible = true
	WORKING = true

func turn_off() -> void:
	if light: light.visible = false
	WORKING = false
