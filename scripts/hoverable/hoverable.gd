extends Node
class_name Hoverable

@export var hover_mesh: MeshInstance3D

func hover() -> void:
	if not hovered():
		hover_mesh.visible = true

func unhover() -> void:
	if hovered():
		hover_mesh.visible = false

func hovered() -> bool:
	if not hover_mesh:
		return true
	return hover_mesh.visible
