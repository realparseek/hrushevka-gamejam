extends Node
class_name InventorySlot

@export var icon: TextureRect

func _ready() -> void:
	pass

func set_item(pickable: Pickable) -> void:
	if pickable:
		icon.texture = pickable.icon
	else:
		icon.texture = null

func is_null() -> bool:
	return icon.texture == null
