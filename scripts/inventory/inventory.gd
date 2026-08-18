extends Node
class_name Inventory

@export var grid_container: GridContainer

var ISLOT: PackedScene = load("res://entities/inventory/slot.tscn")

func _ready() -> void:
	for i in range(grid_container.columns):
		var slot = ISLOT.instantiate()
		grid_container.add_child(slot)

func add_pickable(pickable: Pickable):
	var slot: InventorySlot = null
	for c in grid_container.get_child(0).get_children():
		if c is InventorySlot: 
			slot = c
			break
	slot.set_item(pickable)

func pos_to_index(_pos: Vector2i) -> int:
	return 0
