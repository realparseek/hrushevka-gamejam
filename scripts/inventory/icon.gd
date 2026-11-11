extends TextureRect

signal equip_requested

@export var inventory_slot: InventorySlot

var _drag_started: bool = false

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = event
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if mb.pressed:
		_drag_started = false
	elif not _drag_started:
		equip_requested.emit()

func _get_drag_data(_at_pos: Vector2) -> Variant:
	if inventory_slot.is_empty(): return null
	_drag_started = true
	
	var preview: TextureRect = duplicate()
	preview.position -= Vector2(size.x/2.0, size.y/2.0)
	preview.modulate = Color(preview.modulate, 0.5)
	preview.size = Vector2(40.0, 40.0)
	
	var c: Control = Control.new()
	c.add_child(preview)
	set_drag_preview(c)
	
	return inventory_slot

func _can_drop_data(_at_pos: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	if not inventory_slot.is_empty(): return
	if inventory_slot == data: return
	inventory_slot.set_item(data.PICKABLE)
	data.set_item(null)
