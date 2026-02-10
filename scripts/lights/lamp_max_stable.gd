extends OmniLight3D

@export var base_energy: float = 1.0
@export var flicker_strength: float = 0.003  
@export var flicker_speed: float = 90.0

func _ready():
	light_energy = base_energy
	light_color = Color("ffebc1ff")

func _process(_delta):
	# Только мерцание, без мигания
	var flicker = sin(Time.get_ticks_msec() * 0.001 * flicker_speed) * flicker_strength
	light_energy = base_energy + flicker
