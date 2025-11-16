extends State

@export var light_sources: Array[State]
@export var environment: WorldEnvironment
@export var audio_player: SteamAudioPlayer

func enter() -> void:
	if audio_player:
		audio_player.play()
	for ls in light_sources:
		ls.Transitioned.emit("turnedon", ls.get_parent().current_state)
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	var env_energy: float = environment.environment.ambient_light_energy
	env_energy = lerpf(env_energy, 1.2, delta*3)
	environment.environment.ambient_light_energy = env_energy

func physics_update(delta: float) -> void:
	float(delta)
	pass
