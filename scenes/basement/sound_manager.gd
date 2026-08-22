extends Node3D

@export var sound_streams: Array[AudioStream] = []
#Минимальная и максимальная задержка между воспроизведениями (секунды)
@export var min_delay: float = 5.0
@export var max_delay: float = 15.0
#Радиус разброса источника звука по горизонтали (XZ)
@export var radius: float = 8.0
#Разброс по высоте (Y)
@export var height_offset: float = 2.0
@export var volume_db: float = 0.0
@export var target_node: Node3D = null
#Это для конкретных точек
@export var fixed_spawn_points: Array[Vector3] = []
@export var active: bool = true

var timer: Timer
var rng: RandomNumberGenerator

func _ready():
	if target_node == null:
		var camera = get_viewport().get_camera_3d()
		if camera:
			target_node = camera
		else:
			target_node = self
			push_warning("AmbientSoundManager: target_node not set, using self as reference.")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	timer = Timer.new()
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	_schedule_next()

func _schedule_next():
	if not active:
		return
	var delay = randf_range(min_delay, max_delay)
	timer.start(delay)

func _on_timer_timeout():
	if active:
		_play_random_sound()
	_schedule_next()

func _play_random_sound():
	if sound_streams.is_empty():
		return
	
	var stream = sound_streams[rng.randi_range(0, sound_streams.size() - 1)]
	if stream == null:
		return
	
	var player = AudioStreamPlayer3D.new()
	player.stream = stream
	player.volume_db = volume_db
	
	var target_pos = target_node.global_position
	var spawn_pos = target_pos
	
	if not fixed_spawn_points.is_empty():
		spawn_pos = target_pos + fixed_spawn_points[rng.randi_range(0, fixed_spawn_points.size() - 1)]
	else:
		var offset = Vector3(
			randf_range(-radius, radius),
			randf_range(-height_offset, height_offset),
			randf_range(-radius, radius)
		)
		spawn_pos = target_pos + offset
	
	player.global_position = spawn_pos
	add_child(player)
	player.play()
	player.finished.connect(_on_player_finished.bind(player))

func _on_player_finished(player: AudioStreamPlayer3D):
	player.queue_free()
	
func set_active(value: bool):
	active = value
	if not active:
		timer.stop()
	else:
		if not timer.is_stopped():
			timer.stop()
		_schedule_next()

func play_now():
	_play_random_sound()
