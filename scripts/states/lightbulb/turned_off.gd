extends State

@export var light: OmniLight3D = null
@export var mesh: MeshInstance3D = null

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
