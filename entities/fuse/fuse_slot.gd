extends InventorySlot
class_name FuseSlot

@export var fuse_mesh: MeshInstance3D

func _process(_delta: float) -> void:
	if is_empty() and fuse_mesh.visible:
		fuse_mesh.visible = false
	if not is_empty() and not fuse_mesh.visible:
		fuse_mesh.visible = true
