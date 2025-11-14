extends State

@export var light_sources: Array[State]
@export var environment: WorldEnvironment

func enter() -> void:
	for ls in light_sources:
		ls.Transitioned.emit("turnedoff", ls.get_parent().current_state)
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit("turnedon", self)
	
	var env_energy: float = environment.environment.ambient_light_energy
	env_energy = lerpf(env_energy, 0.05, delta*4)
	environment.environment.ambient_light_energy = env_energy
	
	pass

func physics_update(delta: float) -> void:
	float(delta)
	pass
