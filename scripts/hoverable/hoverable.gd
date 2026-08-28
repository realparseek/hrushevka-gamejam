extends Node
class_name Hoverable

@export var hover_mesh: MeshInstance3D
@export var icon_pos: Node3D

var HOVERED: bool = false

func hover() -> void:
	if not HOVERED:
		if hover_mesh: hover_mesh.visible = true
		HOVERED = true

func unhover() -> void:
	if HOVERED:
		if hover_mesh: hover_mesh.visible = false
		HOVERED = false
