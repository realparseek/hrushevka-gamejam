extends Node
class_name InventorySlot

@export var icon: TextureRect

func set_item(pickable: Pickable) -> void:
	icon.texture = pickable.icon

func set_null() -> void:
	pass

func is_null() -> bool:
	return icon.texture == null
