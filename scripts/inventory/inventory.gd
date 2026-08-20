extends Node
class_name Inventory

@export var pause_menu: PauseMenu
@export var grid_container: GridContainer
@export var move_sound: AudioStreamPlayer
@export var rows: int = 2
@export_range(0.0, 1.0) var open_acceleration: float

const ROWHEIGHT: int = 60

var ISLOT: PackedScene = preload("res://entities/inventory/slot.tscn")
var SLOT_COUNT: int = 0
var ITEM_COUNT: int = 0
var VISIBLE: bool = false
var STARTPOS: Vector2 = Vector2.ZERO

func _ready() -> void:
	for i in range(grid_container.columns*rows):
		var slot = ISLOT.instantiate()
		grid_container.add_child(slot)

	STARTPOS = grid_container.position

func _process(_delta: float) -> void:
	_handle_visibility()

func add_pickable(pickable: Pickable) -> bool:
	for c in grid_container.get_children():
		for cc in c.get_children():
			if cc is not InventorySlot or not cc.is_null(): continue
			cc.set_item(pickable)
			return true
	return false

func close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	VISIBLE = false

func open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	VISIBLE = true

func opened() -> bool:
	return VISIBLE

func _handle_visibility() -> void:
	if Input.is_action_just_pressed("ui_inventory") and pause_menu and not pause_menu.PAUSED:
		if VISIBLE: close()
		else: open()
	
	var fposy: float = STARTPOS.y - rows * ROWHEIGHT
	fposy += float(not VISIBLE) * rows * ROWHEIGHT
	grid_container.position.y = lerp(grid_container.position.y, fposy, open_acceleration)
