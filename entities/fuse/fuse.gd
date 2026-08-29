extends Node

@export var rigid_body: RigidBody3D
@export var audio_player: SpatialAudioPlayer3D
@export var main_hit_sound: AudioStream
@export var other_hit_sounds: Array[AudioStream]
@export var min_volume: float = -20.0
@export var max_volume: float = 0.0
@export var min_speed: float = 0.5
@export var max_speed: float = 10.0
@export var cooldown: float = 0.15
@export var volume_curve_power: float = 1.5

var _last_play_time: float = 0.0

func _ready():
	if not rigid_body:
		push_error("RigidBody не назначен!")
		return
	rigid_body.body_entered.connect(_on_body_entered)
	rigid_body.linear_velocity = Vector3(0.0, 0.0, 2.0)
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 8

func _physics_process(_delta):
	var state = PhysicsServer3D.body_get_direct_state(rigid_body.get_rid())
	if not state:
		return
	
	var contact_count = state.get_contact_count()
	if contact_count == 0:
		return
	
	var now = Time.get_ticks_msec() / 1000.0
	if now - _last_play_time < cooldown:
		return
	
	var max_impact_speed = 0.0
	for i in range(contact_count):
		var normal = state.get_contact_local_normal(i)
		var speed = abs(state.linear_velocity.dot(normal))
		if speed > max_impact_speed:
			max_impact_speed = speed
	
	if max_impact_speed < min_speed:
		return
	
	var stream: AudioStream
	if other_hit_sounds.size() > 0:
		stream = other_hit_sounds[randi_range(0, other_hit_sounds.size() - 1)]
	else:
		stream = main_hit_sound
	if not stream:
		return
	
	var clamped = clamp(max_impact_speed, min_speed, max_speed)
	var t = (clamped - min_speed) / (max_speed - min_speed)
	t = pow(t, volume_curve_power) 
	var volume = lerp(min_volume, max_volume, t)
	
	print("Speed: ", max_impact_speed, "  Volume: ", volume)
	_play_sound(stream, volume)
	_last_play_time = now

func _on_body_entered(_body: Node):
	pass

func _play_sound(stream: AudioStream, volume_db: float):
	if not stream or not audio_player:
		return
	if audio_player.playing:
		audio_player.stop()
	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.play()
