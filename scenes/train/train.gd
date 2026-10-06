extends Node
class_name Train

func move_regions() -> void:
	$"../../../terrain/terrain".offset.x = -1
	$"../../../terrain/terrain".run = true
	print("moved")

func rewind_regions() -> void:
	$"../../../terrain/terrain".offset.x = 1
	$"../../../terrain/terrain".run = true
	print("rewind")
