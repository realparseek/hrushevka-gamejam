extends Node
class_name Hoverable

@export var hover_mesh: MeshInstance3D

var HOVERED: bool = false

func hover() -> void:
	if not hovered():
		if hover_mesh: hover_mesh.visible = true
		HOVERED = true

func unhover() -> void:
	if hovered():
		if hover_mesh: hover_mesh.visible = false
		HOVERED = false

func hovered() -> bool:
	if not hover_mesh:
		return HOVERED
	return hover_mesh.visible
