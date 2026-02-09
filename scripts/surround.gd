extends Node3D

@export var audio_files: Array[AudioStream]
@export var min_wait_time: float = 60.0
@export var max_wait_time: float = 600.0

#AudioStreamPlayer3D
@export_group("Audio Player Settings")
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var max_db: float = 3.0
@export var attenuation_filter_cutoff_hz: float = 5000.0
@export var attenuation_filter_db: float = -24.0
@export var doppler_tracking: int = 0 # 0 = Disabled, 1 = Idle, 2 = Physics
@export var emission_angle_degrees: float = 45.0
@export var emission_angle_filter_attenuation_db: float = -12.0
@export var max_distance: float = 0.0
@export var attenuation_model: int = 0 # 0 = Inverse, 1 = Inverse Square, 2 = Logarithmic, 3 = Disabled
@export var panning_strength: float = 1.0
@export var unit_size: float = 1.0 # Размер источника звука
@export var pitch_scale_randomness: float = 0.1 # Случайное изменение тона

var _available_audio: Array[AudioStream]
var _audio_player: AudioStreamPlayer3D
var _timer: Timer
var _is_playing: bool = false

func _ready():
	_audio_player = AudioStreamPlayer3D.new()
	_configure_audio_player(_audio_player)
	_audio_player.finished.connect(_on_sound_finished)
	add_child(_audio_player)
	
	_timer = Timer.new()
	_timer.timeout.connect(_try_play_next_sound)
	add_child(_timer)
	
	_reset_audio_list()
	
	_start_new_timer()

func _configure_audio_player(player: AudioStreamPlayer3D):
	
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.max_db = max_db
	player.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
	player.attenuation_filter_db = attenuation_filter_db
	player.doppler_tracking = doppler_tracking as AudioStreamPlayer3D.DopplerTracking
	player.emission_angle_degrees = emission_angle_degrees
	player.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
	player.max_distance = max_distance
	player.attenuation_model = attenuation_model as AudioStreamPlayer3D.AttenuationModel
	player.panning_strength = panning_strength
	player.unit_size = unit_size

func _reset_audio_list():
	_available_audio.clear()
	_available_audio.append_array(audio_files)
	
	_shuffle_array(_available_audio)

func _shuffle_array(array: Array):
	for i in range(array.size()):
		var j = randi() % array.size()
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp

func _start_new_timer():
	var wait_time = randf_range(min_wait_time, max_wait_time)
	_timer.start(wait_time)

func _try_play_next_sound():
	
	if _is_playing:
		_start_new_timer()
		return
	
	if _available_audio.is_empty():
		_reset_audio_list()
	
	# первый звук из списка
	var selected_audio = _available_audio.pop_front()
	
	# случайное изменение тона
	if pitch_scale_randomness > 0:
		_audio_player.pitch_scale = pitch_scale * randf_range(1.0 - pitch_scale_randomness, 1.0 + pitch_scale_randomness)
	else:
		_audio_player.pitch_scale = pitch_scale
	
	
	_audio_player.stream = selected_audio
	_audio_player.play()
	_is_playing = true
	
	

func _on_sound_finished():
	
	_is_playing = false
	_start_new_timer()
