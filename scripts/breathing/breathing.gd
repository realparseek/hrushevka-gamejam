extends Node
class_name Breathing

signal stamina_changed(value: float)
signal exhausted()
signal recovered()

const SILENT_DB: float = -80.0

@export_subgroup("Ссылки")
@export var player: CharacterBody3D
@export var fps_movement: FPSMovement
@export var pause_menu: PauseMenu
@export var audio: AudioStreamPlayer

@export_subgroup("Звуки")
@export var calm_stream: AudioStream
@export var sprint_stream: AudioStream
@export var recover_stream: AudioStream
@export var gasp_stream: AudioStream

@export_subgroup("Громкость (дБ)")
@export var calm_volume_db: float = -26.0
@export var sprint_volume_db: float = -14.0
@export var recover_volume_db: float = -10.0
@export var gasp_volume_db: float = -8.0

@export_subgroup("Выносливость")
@export var drain_rate: float = 0.30  # Стамина
@export var recover_rate: float = 0.255  # Рекавер стамины
@export var sprint_min_speed: float = 1.6
@export var exhausted_threshold: float = 0.125
@export var recovered_threshold: float = 0.425 

@export_subgroup("Переходы")
@export var crossfade_time: float = 1.5
@export var state_min_time: float = 0.4
@export var pant_enter: float = 0.22
@export var pant_exit: float = 0.12
@export var pant_smoothing: float = 1.6
@export var calm_enabled: bool = true

const STATE_CALM: int = 0
const STATE_SPRINT: int = 1
const STATE_RECOVER: int = 2

var STAMINA: float = 1.5
var PANT: float = 0.0
var SPRINTING: bool = false

var _state: int = STATE_CALM
var _state_time: float = 0.0
var _was_exhausted: bool = false
var _sprint_blocked: bool = false
var _last_emitted: float = -1.0
var _stopped_for_pause: bool = false
var _just_stopped_sprinting: bool = false
var _was_sprinting: bool = false
var _sprint_entropy: float = 0.0
var _entropy_decay: float = 1.5

var _out: AudioStreamPlayer
var _in: AudioStreamPlayer
var _out_db: float = SILENT_DB
var _fade: float = 0.0

func _ready() -> void:
	STAMINA = 1.5
	if audio == null:
		audio = AudioStreamPlayer.new()
		add_child(audio)
	var second: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(second)
	_out = second
	_in = audio
	audio.finished.connect(_on_player_finished.bind(audio))
	second.finished.connect(_on_player_finished.bind(second))
	_switch_to(_stream_for_state())

func can_sprint() -> bool:
	return STAMINA > exhausted_threshold and not _sprint_blocked

func _process(delta: float) -> void:
	if pause_menu and pause_menu.PAUSED:
		if _in and _in.playing:
			_in.stop()
		if _out and _out.playing:
			_out.stop()
		_stopped_for_pause = true
		return
	if _stopped_for_pause:
		_stopped_for_pause = false
		_fade = 1.0
		_switch_to(_stream_for_state())
	if player == null or delta <= 0.0:
		return

	var planar_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	var crouched: bool = fps_movement != null and fps_movement.CROUCHED
	var run_held: bool = Input.is_action_pressed("move_run") if fps_movement == null else fps_movement.RUNNING
	var wants_sprint: bool = run_held and not crouched \
		and planar_speed >= sprint_min_speed and player.is_on_floor()

	if _sprint_blocked and STAMINA >= recovered_threshold:
		_sprint_blocked = false
		_was_exhausted = false

	SPRINTING = wants_sprint and not _sprint_blocked and STAMINA > exhausted_threshold
	
	var should_stop_sprinting: bool = (not wants_sprint or STAMINA <= 0.0) and SPRINTING
	if should_stop_sprinting:
		SPRINTING = false
		_just_stopped_sprinting = true
	elif wants_sprint and not _was_sprinting and STAMINA > exhausted_threshold:
		_just_stopped_sprinting = false

	_was_sprinting = SPRINTING

	if SPRINTING and STAMINA > 0.0:
		STAMINA = maxf(STAMINA - drain_rate * delta, 0.0)
		_just_stopped_sprinting = false
		_sprint_entropy = minf(_sprint_entropy + 0.05, 1.0)
		if STAMINA <= 0.0 and not _sprint_blocked:
			_sprint_blocked = true
			_was_exhausted = true
			exhausted.emit()
			_play_once(gasp_stream, gasp_volume_db)
	elif not SPRINTING:
		STAMINA = minf(STAMINA + recover_rate * delta, 1.0)
		_sprint_entropy = maxf(_sprint_entropy - _entropy_decay * delta, 0.0)
		if _just_stopped_sprinting and STAMINA <= exhausted_threshold and not _was_exhausted and not _sprint_blocked:
			_was_exhausted = true
			_sprint_blocked = true
			exhausted.emit()
			_play_once(gasp_stream, gasp_volume_db)

	PANT = lerpf(PANT, clampf(1.0 - STAMINA, 0.0, 1.0), clampf(pant_smoothing * delta, 0.0, 1.0))

	_update_state(delta)
	_update_fade(delta)

func _desired_state() -> int:
	if SPRINTING and STAMINA > exhausted_threshold:
		return STATE_SPRINT
	var threshold: float = pant_exit if _state == STATE_RECOVER else pant_enter
	if PANT > threshold:
		return STATE_RECOVER
	return STATE_CALM

func _update_state(delta: float) -> void:
	_state_time += delta
	var desired: int = _desired_state()
	if desired != _state and _state_time >= state_min_time:
		_state = desired
		_state_time = 0.0
		_switch_to(_stream_for_state())

func _update_fade(delta: float) -> void:
	var target_db: float = _current_db() if (_in != null and _in.stream != null) else SILENT_DB
	if _fade < 1.0:
		_fade = minf(1.0, _fade + delta / maxf(crossfade_time, 0.01))
	var t: float = _fade * _fade * (3.0 - 2.0 * _fade)
	if _in != null and _in.playing:
		_in.volume_db = lerpf(SILENT_DB, target_db, t)
	if _out != null and _out.playing:
		_out.volume_db = lerpf(_out_db, SILENT_DB, t)
		if _fade >= 1.0:
			_out.stop()

func _switch_to(stream: AudioStream) -> void:
	if _in != null and _in.stream == stream and _in.playing:
		return
	var tmp: AudioStreamPlayer = _out
	_out = _in
	_in = tmp
	if _out != null:
		_out_db = _out.volume_db
	_fade = 0.0
	if _in == null:
		return
	_in.stream = stream
	if stream == null:
		return
	_in.volume_db = SILENT_DB
	_in.play()

func _current_db() -> float:
	var base: float = _volume_for_state()
	var extra: float = 0.0
	if _state == STATE_SPRINT:
		extra = 5.0 * PANT
	elif _state == STATE_RECOVER:
		extra = 3.0 * PANT
	return base + extra

func _stream_for_state() -> AudioStream:
	match _state:
		STATE_SPRINT:
			return sprint_stream
		STATE_RECOVER:
			return recover_stream
		_:
			return calm_stream if calm_enabled else null

func _volume_for_state() -> float:
	match _state:
		STATE_SPRINT:
			return sprint_volume_db
		STATE_RECOVER:
			return recover_volume_db
		_:
			return calm_volume_db

func _on_player_finished(p: AudioStreamPlayer) -> void:
	if p == null or p.stream == null:
		return
	if p == _in and p.stream == _stream_for_state():
		p.play()

func _play_once(stream: AudioStream, db: float) -> void:
	if stream == null:
		return
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
