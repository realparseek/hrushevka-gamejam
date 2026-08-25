extends Node

@export var audio_player: SpatialAudioPlayer3D
@export var main_hit_sound: AudioStream
@export var other_hit_sounds: Array[AudioStream]
@export var player_hit_sound: AudioStream
@export var min_volume: float = -20.0
@export var max_volume: float = 0.0
@export var min_speed: float = 0.5
@export var max_speed: float = 10.0
@export var cooldown: float = 0.3
@export var volume_curve_power: float = 1.5
@export var debug: bool = true

var rigid_body: RigidBody3D
var _last_play_time: float = 0.0
var _had_contact_last_frame: bool = false
var _players: Array[SpatialAudioPlayer3D] = []

func _ready():
	rigid_body = get_parent() as RigidBody3D
	if not rigid_body:
		push_error("Родительский узел не RigidBody3D!")
		return
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 8

	if audio_player:
		_players.append(audio_player)
		var player2 = SpatialAudioPlayer3D.new()
		player2.bus = audio_player.bus
		player2.max_distance = audio_player.max_distance
		player2.attenuation_model = audio_player.attenuation_model
		add_child(player2)
		_players.append(player2)
	else:
		push_error("Нет аудиоплеера!")

func _physics_process(_delta):
	var state = PhysicsServer3D.body_get_direct_state(rigid_body.get_rid())
	if not state:
		_had_contact_last_frame = false
		return

	var contact_count = state.get_contact_count()
	if contact_count == 0:
		_had_contact_last_frame = false
		return

	var now = Time.get_ticks_msec() / 1000.0
	if now - _last_play_time < cooldown:
		_had_contact_last_frame = true
		return

	var max_impact_speed = 0.0
	var first_collider = null
	for i in range(contact_count):
		var collider = state.get_contact_collider_object(i)
		var local_normal = state.get_contact_local_normal(i)
		var global_normal = state.transform.basis * local_normal
		var speed = abs(state.linear_velocity.dot(global_normal))
		if speed > max_impact_speed:
			max_impact_speed = speed
			first_collider = collider

	var is_landing = not _had_contact_last_frame
	_had_contact_last_frame = true

	if max_impact_speed < min_speed and not is_landing:
		return

	var effective_speed = max_impact_speed
	if is_landing and effective_speed < min_speed:
		effective_speed = min_speed

	var stream: AudioStream
	if _is_player(first_collider):
		stream = player_hit_sound
	else:
		stream = main_hit_sound
		if other_hit_sounds.size() > 0:
			stream = other_hit_sounds[randi_range(0, other_hit_sounds.size() - 1)]
	if not stream:
		return

	var speed_range = max_speed - min_speed
	var t: float
	if speed_range == 0:
		t = 0.0
	else:
		t = clamp((effective_speed - min_speed) / speed_range, 0.0, 1.0)
	t = pow(t, volume_curve_power)
	var volume = lerp(min_volume, max_volume, t)

	if debug:
		print("Speed: ", effective_speed, "  Volume: ", volume)

	var player_to_use = null
	for p in _players:
		if not p.playing:
			player_to_use = p
			break
	if not player_to_use:
		return

	player_to_use.stream = stream
	player_to_use.volume_db = volume
	player_to_use.play()
	_last_play_time = now

func _is_player(body: Node) -> bool:
	if not body:
		return false
	if body is CharacterBody3D:
		return body.is_in_group("player") or body.name.to_lower() == "player"
	return false
