extends State

@export var light_sources: Array[State]
@export var environment: WorldEnvironment

func enter() -> void:
	for ls in light_sources:
		ls.Transitioned.emit("turnedon", ls.get_parent().current_state)
	environment.environment.ambient_light_color = Color(0.647, 0.516, 0.413) * 1.3
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit("turnedoff", self)
	
	float(delta)
	pass

func physics_update(delta: float) -> void:
	float(delta)
	pass
