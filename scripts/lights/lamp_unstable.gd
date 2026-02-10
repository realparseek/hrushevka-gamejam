extends OmniLight3D


var base_energy: float = 1
var flicker_strength: float = 0.01  
var flicker_speed: float = 90     


var blink_timer: float = 0.0
var blink_interval: float = 20.0  
var is_blinking: bool = false
var blink_phase: float = 0.0
var blink_type: int = 0

func _ready():
	light_energy = base_energy
	light_color = Color("ffebc1ff")
	blink_timer = randf_range(8.0, blink_interval)

func _process(delta):
	blink_timer -= delta
	
	if blink_timer <= 0.0 and !is_blinking:
		start_blink()
	
	if is_blinking:
		handle_blink(delta)
	else:
		
		var flicker = sin(Time.get_ticks_msec() * 0.001 * flicker_speed) * flicker_strength
		light_energy = base_energy + flicker

func start_blink():
	is_blinking = true
	blink_phase = 0.0
	blink_type = randi() % 3

func handle_blink(delta):
	blink_phase += delta
	
	match blink_type:
		0: 
			if blink_phase < 0.15:  
				light_energy = 0.0
			elif blink_phase < 0.25:
				light_energy = base_energy
			else:
				finish_blink()
				
		1:  
			if blink_phase < 0.4:
				light_energy = 0.0
			elif blink_phase < 0.5:
				light_energy = base_energy
			else:
				finish_blink()
				
		2:  
			if blink_phase < 0.1:
				light_energy = 0.0
			elif blink_phase < 0.15:
				light_energy = base_energy
			elif blink_phase < 0.25:
				light_energy = 0.0
			elif blink_phase < 0.35:
				light_energy = base_energy
			else:
				finish_blink()

func finish_blink():
	is_blinking = false
	light_energy = base_energy
	blink_timer = randf_range(15.0, 40.0)  
