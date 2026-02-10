extends State

@export var light_sources: Array[State]
@export var audio_player: RaytracedAudioPlayer3D

@onready var environment: WorldEnvironment = $'../../../../env'

func enter() -> void:
	if audio_player:
		audio_player.play()
	for ls in light_sources:
		ls.Transitioned.emit("turnedoff", ls.get_parent().current_state)
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	var env_energy: float = environment.environment.ambient_light_energy
	env_energy = lerpf(env_energy, 0.07, delta*4)
	environment.environment.ambient_light_energy = env_energy

func physics_update(delta: float) -> void:
	float(delta)
	pass
