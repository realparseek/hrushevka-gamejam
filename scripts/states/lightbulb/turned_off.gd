extends State

@onready var light: OmniLight3D = get_parent().get_parent().get_child(3)
@onready var mesh: MeshInstance3D = get_parent().get_parent().get_child(1)

func enter() -> void:
	light.visible = false
	mesh.visible = true
	
func exit() -> void:
	mesh.visible = false

func update(delta: float) -> void:
	float(delta)
	pass

func physics_update(delta: float) -> void:
	float(delta)
	pass
