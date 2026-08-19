extends Node
class_name Inventory

@export var grid_container: GridContainer
@export var move_sound: AudioStreamPlayer

var ISLOT: PackedScene = load("res://entities/inventory/slot.tscn")
var SLOT_COUNT: int = 0
var ITEM_COUNT: int = 0

func _ready() -> void:
	for i in range(grid_container.columns):
		var slot = ISLOT.instantiate()
		grid_container.add_child(slot)

func add_pickable(pickable: Pickable) -> bool:
	for c in grid_container.get_children():
		for cc in c.get_children():
			if cc is InventorySlot and cc.is_null(): 
				cc.set_item(pickable)
				return true
	return false
