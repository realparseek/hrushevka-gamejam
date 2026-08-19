extends Node
class_name InventorySlot

@export var icon: TextureRect

var PICKABLE: Pickable = null

func set_item(pickable: Pickable) -> void:
	if pickable:
		PICKABLE = pickable.duplicate()
		icon.texture = PICKABLE.icon
	else:
		PICKABLE = null
		icon.texture = null

func is_null() -> bool:
	return PICKABLE == null
