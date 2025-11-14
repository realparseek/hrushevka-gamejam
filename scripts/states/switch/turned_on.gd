extends State

@export var light_sources: Array[State]
@export var environment: WorldEnvironment

func enter() -> void:
	for ls in light_sources:
		ls.Transitioned.emit("turnedon", ls.get_parent().current_state)
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit("turnedoff", self)
	
	var env_energy: float = environment.environment.ambient_light_energy
	env_energy = lerpf(env_energy, 1.2, delta*3)
	environment.environment.ambient_light_energy = env_energy

func physics_update(delta: float) -> void:
	float(delta)
	pass
