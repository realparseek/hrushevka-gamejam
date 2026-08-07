extends Node
class_name Inventory

@export var grid_container: GridContainer

var ITEMS: Array[Pickable] = []
var NULL_SLOT: PackedScene = preload('res://entities/islot/islot.tscn')

func _ready() -> void:
	for i in range(grid_container.columns):
		var slot = NULL_SLOT.instantiate()
		grid_container.add_child(slot)
	
	ITEMS.resize(4)

func add_pickable(pickable: Pickable):
	var trect: TextureRect = grid_container.get_child(0).get_child(1)
	trect.texture = pickable.icon
	ITEMS.append(pickable)

func pos_to_index(_pos: Vector2i) -> int:
	return 0
