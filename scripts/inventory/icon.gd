extends TextureRect

func _get_drag_data(_at_pos: Vector2) -> Variant:
	if not texture: return
	
	var preview: TextureRect = duplicate()
	preview.position -= Vector2(size.x/2.0, size.y/2.0)
	preview.modulate = Color(preview.modulate, 0.5)
	
	var c: Control = Control.new()
	c.add_child(preview)
	
	set_drag_preview(c)
	return self

func _can_drop_data(_at_pos: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	texture = data.texture
	data.texture = null
