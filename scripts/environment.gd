extends WorldEnvironment

@onready var ambient_energy: float = 1.0

func _process(delta: float) -> void:
	environment.ambient_light_energy = lerp(environment.ambient_light_energy, ambient_energy, delta*2)
