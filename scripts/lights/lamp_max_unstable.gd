extends OmniLight3D

@export var base_energy: float = 1.0
@export var flicker_strength: float = 0.01  
@export var flicker_speed: float = 70.0
@export var min_blink_interval: float = 8.0
@export var max_blink_interval: float = 30.0

var blink_timer: float = 0.0
var is_blinking: bool = false
var blink_phase: float = 0.0
var current_pattern: Array = []
var pattern_total_duration: float = 0.0

func _ready():
	light_energy = base_energy
	light_color = Color("ffebc1ff")
	reset_blink_timer()

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
	generate_blink_pattern()

func generate_blink_pattern():
	var pattern_type = randi() % 6
	pattern_total_duration = 0.0
	
	match pattern_type:
		0: # Одиночное короткое мигание
			current_pattern = [
				{"duration": 0.1, "energy": 0.0},
				{"duration": 0.05, "energy": base_energy}
			]
		1: # Одиночное длинное мигание
			current_pattern = [
				{"duration": 0.3, "energy": 0.0},
				{"duration": 0.1, "energy": base_energy}
			]
		2: # Двойное мигание
			current_pattern = [
				{"duration": 0.08, "energy": 0.0},
				{"duration": 0.06, "energy": base_energy},
				{"duration": 0.08, "energy": 0.0},
				{"duration": 0.1, "energy": base_energy}
			]
		3: # Тройное быстрое мигание
			current_pattern = [
				{"duration": 0.05, "energy": 0.0},
				{"duration": 0.04, "energy": base_energy},
				{"duration": 0.05, "energy": 0.0},
				{"duration": 0.04, "energy": base_energy},
				{"duration": 0.05, "energy": 0.0},
				{"duration": 0.08, "energy": base_energy}
			]
		4: # Пульсирующее мигание
			current_pattern = [
				{"duration": 0.1, "energy": 0.0},
				{"duration": 0.03, "energy": base_energy},
				{"duration": 0.07, "energy": 0.0},
				{"duration": 0.05, "energy": base_energy * 0.5},
				{"duration": 0.05, "energy": base_energy}
			]
		5: # Случайное сложное мигание
			var blink_count = randi() % 3 + 2  # 2-4 мигания
			current_pattern = []
			
			for i in blink_count:
				var off_duration = randf_range(0.03, 0.15)
				var on_duration = randf_range(0.02, 0.08)
				var energy = base_energy if i == blink_count - 1 else randf_range(0.3, 1.0) * base_energy
				
				current_pattern.append({"duration": off_duration, "energy": 0.0})
				current_pattern.append({"duration": on_duration, "energy": energy})
	
	for step in current_pattern:
		pattern_total_duration += step.duration

func handle_blink(delta):
	blink_phase += delta
	
	var accumulated_time = 0.0
	var current_energy = base_energy
	
	for step in current_pattern:
		if blink_phase < accumulated_time + step.duration:
			current_energy = step.energy
			break
		accumulated_time += step.duration
	
	light_energy = current_energy
	
	if blink_phase >= pattern_total_duration:
		finish_blink()

func finish_blink():
	is_blinking = false
	light_energy = base_energy
	reset_blink_timer()

func reset_blink_timer():
	blink_timer = randf_range(min_blink_interval, max_blink_interval)
