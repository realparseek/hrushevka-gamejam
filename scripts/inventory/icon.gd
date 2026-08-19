extends TextureRect

@export var inventory_slot: InventorySlot

func _get_drag_data(_at_pos: Vector2) -> Variant:
	if inventory_slot.is_null(): return null
	
	var preview: TextureRect = duplicate()
	preview.position -= Vector2(size.x/2.0, size.y/2.0)
	preview.modulate = Color(preview.modulate, 0.5)
	
	var c: Control = Control.new()
	c.add_child(preview)
	
	set_drag_preview(c)
	return inventory_slot

func _can_drop_data(_at_pos: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	if not inventory_slot.is_null(): return
	if inventory_slot == data: return
	inventory_slot.set_item(data.PICKABLE)
	data.set_item(null)
