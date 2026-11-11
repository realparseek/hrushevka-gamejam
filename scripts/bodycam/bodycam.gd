extends Camera3D
class_name Bodycam

@export_subgroup("Ссылки")
@export var player: CharacterBody3D
@export var head: Node3D
@export var fps_movement: FPSMovement
@export var pause_menu: PauseMenu
@export var breathing: Breathing

@export_subgroup("Инерция мыши")
@export var drag_enabled: bool = true
@export_range(0.0, 1.0, 0.01) var drag_pitch: float = 0.16
@export_range(0.0, 1.0, 0.01) var drag_yaw: float = 0.12
@export var drag_recovery: float = 10.0
@export var drag_max_deg: float = 4.0

@export_subgroup("Инерция движения")
@export var sway_enabled: bool = true
@export var sway_per_speed: float = 0.010
@export var sway_stiffness: float = 60.0
@export var sway_damping: float = 14.0
@export var sway_max: float = 0.10

@export_subgroup("Наклон и крен")
@export var lean_enabled: bool = true
@export var strafe_roll_deg: float = 0.9
@export var turn_roll_deg: float = 0.35
@export var accel_pitch_deg: float = 0.9
@export var roll_recovery: float = 6.0

@export_subgroup("Дыхание")
@export var breath_enabled: bool = true
@export var breath_amplitude: float = 0.012
@export var breath_speed: float = 1.2
@export var breath_roll_deg: float = 1.0
@export var pant_breath_scale: float = 1.6

@export_subgroup("Покачивание")
@export var bob_enabled: bool = true
@export var bob_lateral: float = 0.010
@export var bob_speed: float = 2.0

@export_subgroup("Шаги и приземление")
@export var impact_enabled: bool = true
@export var step_dip: float = 2.0
@export var step_pitch: float = 1.5
@export var impact_impulse: float = 2.5
@export var impact_roll_deg: float = 3.5
@export var kick_stiffness: float = 140.0
@export var kick_damping: float = 15.0
@export var kick_max: float = 0.35

@export_subgroup("Дрожание")
@export var shake_enabled: bool = true
@export var shake_walk_deg: float = 0.325
@export var shake_step_deg: float = 0.156
@export var shake_pant_deg: float = 0.65
@export var shake_frequency: float = 18.2
@export var shake_position: float = 0.0052

@export_subgroup("Присед")
@export var crouch_camera_drop: float = 0.0
@export var crouch_speed: float = 7.0

@export_subgroup("FOV")
@export var fov_enabled: bool = true
@export var run_fov_bonus: float = 5.0
@export var crouch_fov_penalty: float = -2.5
@export var fov_speed: float = 5.0

var _base_position: Vector3 = Vector3.ZERO
var _base_rotation: Vector3 = Vector3.ZERO
var _base_fov: float = 75.0

var _sway_offset: Vector3 = Vector3.ZERO
var _sway_velocity: Vector3 = Vector3.ZERO

var _drag_pitch_offset: float = 0.0
var _drag_yaw_offset: float = 0.0
var _prev_head_pitch: float = 0.0
var _prev_player_yaw: float = 0.0

var _lean_roll: float = 0.0
var _turn_roll: float = 0.0
var _accel_pitch: float = 0.0
var _prev_forward_speed: float = 0.0
var _yaw_rate: float = 0.0

var _breath_time: float = 0.0
var _breath_y: float = 0.0
var _breath_roll: float = 0.0

var _bob_time: float = 0.0
var _bob_x: float = 0.0

var _kick_offset: Vector3 = Vector3.ZERO
var _kick_velocity: Vector3 = Vector3.ZERO
var _kick_pitch: float = 0.0
var _kick_pitch_velocity: float = 0.0
var _kick_roll: float = 0.0
var _kick_roll_velocity: float = 0.0

var _crouch_offset: float = 0.0

var _shake_time: float = 0.0
var _step_pulse: float = 0.0
var _noise: FastNoiseLite

func _ready() -> void:
	_base_position = position
	_base_rotation = rotation
	_base_fov = fov

	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.seed = randi()
	_noise.frequency = 1.0

	if head:
		_prev_head_pitch = head.rotation.x
	if player:
		_prev_player_yaw = player.rotation.y
	if fps_movement:
		if fps_movement.has_signal("stepped"):
			fps_movement.stepped.connect(_on_stepped)
		if fps_movement.has_signal("landed"):
			fps_movement.landed.connect(_on_landed)

func _process(delta: float) -> void:
	if pause_menu and pause_menu.PAUSED:
		return
	if not player or not head or delta <= 0.0:
		return

	var planar_velocity: Vector3 = Vector3(player.velocity.x, 0.0, player.velocity.z)
	var speed: float = planar_velocity.length()
	var local_velocity: Vector3 = player.global_transform.basis.inverse() * planar_velocity
	var pant: float = breathing.PANT if breathing else 0.0

	_update_drag(delta)
	_update_sway(delta, local_velocity)
	_update_lean(delta, local_velocity)
	_update_turn(delta)
	_update_accel(delta, local_velocity)
	_update_kick(delta)
	_update_crouch(delta)
	_update_breath(delta, speed, pant)
	_update_bob(delta, speed)
	_step_pulse = lerpf(_step_pulse, 0.0, clampf(delta * 6.0, 0.0, 1.0))
	_shake_time += delta
	_apply(delta, speed, pant)

func _update_drag(delta: float) -> void:
	var pitch_delta: float = head.rotation.x - _prev_head_pitch
	_prev_head_pitch = head.rotation.x
	var yaw_delta: float = wrapf(player.rotation.y - _prev_player_yaw, -PI, PI)
	_prev_player_yaw = player.rotation.y
	_yaw_rate = yaw_delta / delta

	if drag_enabled:
		_drag_pitch_offset -= pitch_delta * drag_pitch
		_drag_yaw_offset -= yaw_delta * drag_yaw

	var limit: float = deg_to_rad(drag_max_deg)
	_drag_pitch_offset = clampf(_drag_pitch_offset, -limit, limit)
	_drag_yaw_offset = clampf(_drag_yaw_offset, -limit, limit)
	var recovery: float = clampf(drag_recovery * delta, 0.0, 1.0)
	_drag_pitch_offset = lerpf(_drag_pitch_offset, 0.0, recovery)
	_drag_yaw_offset = lerpf(_drag_yaw_offset, 0.0, recovery)

func _update_sway(delta: float, local_velocity: Vector3) -> void:
	var target: Vector3 = Vector3.ZERO
	if sway_enabled:
		target = Vector3(-local_velocity.x, 0.0, -local_velocity.z) * sway_per_speed

	var force: Vector3 = (target - _sway_offset) * sway_stiffness - _sway_velocity * sway_damping
	_sway_velocity += force * delta
	_sway_offset += _sway_velocity * delta
	_sway_offset = _sway_offset.limit_length(sway_max)

func _update_lean(delta: float, local_velocity: Vector3) -> void:
	var target_roll: float = 0.0
	if lean_enabled:
		target_roll = -local_velocity.x * deg_to_rad(strafe_roll_deg)
	_lean_roll = lerpf(_lean_roll, target_roll, clampf(roll_recovery * delta, 0.0, 1.0))

func _update_turn(delta: float) -> void:
	var target: float = clampf(_yaw_rate * deg_to_rad(turn_roll_deg), deg_to_rad(-3.0), deg_to_rad(3.0))
	_turn_roll = lerpf(_turn_roll, target, clampf(roll_recovery * delta, 0.0, 1.0))

func _update_accel(delta: float, local_velocity: Vector3) -> void:
	var forward_speed: float = -local_velocity.z
	var accel: float = (forward_speed - _prev_forward_speed) / delta
	_prev_forward_speed = forward_speed
	var target: float = clampf(accel * deg_to_rad(accel_pitch_deg) / 6.0, deg_to_rad(-3.0), deg_to_rad(3.0))
	_accel_pitch = lerpf(_accel_pitch, target, clampf(4.0 * delta, 0.0, 1.0))

func _update_kick(delta: float) -> void:
	var force: Vector3 = -_kick_offset * kick_stiffness - _kick_velocity * kick_damping
	_kick_velocity += force * delta
	_kick_offset += _kick_velocity * delta
	_kick_offset = _kick_offset.limit_length(kick_max)

	var pitch_force: float = -_kick_pitch * kick_stiffness - _kick_pitch_velocity * kick_damping
	_kick_pitch_velocity += pitch_force * delta
	_kick_pitch += _kick_pitch_velocity * delta
	_kick_pitch = clampf(_kick_pitch, deg_to_rad(-6.0), deg_to_rad(6.0))

	var roll_force: float = -_kick_roll * kick_stiffness - _kick_roll_velocity * kick_damping
	_kick_roll_velocity += roll_force * delta
	_kick_roll += _kick_roll_velocity * delta
	var roll_limit: float = deg_to_rad(impact_roll_deg)
	_kick_roll = clampf(_kick_roll, -roll_limit, roll_limit)

func _update_crouch(delta: float) -> void:
	var target: float = 0.0
	if fps_movement and fps_movement.CROUCHED:
		target = -crouch_camera_drop
	_crouch_offset = lerpf(_crouch_offset, target, clampf(crouch_speed * delta, 0.0, 1.0))

func _update_breath(delta: float, speed: float, pant: float) -> void:
	if not breath_enabled:
		var relax: float = clampf(delta * 3.0, 0.0, 1.0)
		_breath_y = lerpf(_breath_y, 0.0, relax)
		_breath_roll = lerpf(_breath_roll, 0.0, relax)
		return

	var intensity: float = 1.0 + pant * pant_breath_scale
	_breath_time += delta * breath_speed * (1.0 + pant * 1.2)
	var calm: float = clampf(1.0 - speed * 0.45, 0.0, 1.0)
	var base_amount: float = maxf(calm, 0.25 + pant * 0.75)
	_breath_y = sin(_breath_time) * breath_amplitude * intensity * base_amount
	_breath_roll = sin(_breath_time * 0.5) * deg_to_rad(breath_roll_deg) * intensity * maxf(calm, 0.3)

func _update_bob(delta: float, speed: float) -> void:
	if not bob_enabled or speed < 0.1:
		_bob_x = lerpf(_bob_x, 0.0, clampf(delta * 6.0, 0.0, 1.0))
		return
	_bob_time += delta * bob_speed * speed
	var amount: float = clampf(speed / 3.0, 0.0, 1.4)
	_bob_x = sin(_bob_time) * bob_lateral * amount

func _apply(delta: float, speed: float, pant: float) -> void:
	var shake_pitch: float = 0.0
	var shake_yaw: float = 0.0
	var shake_roll: float = 0.0
	var shake_pos: Vector3 = Vector3.ZERO

	if shake_enabled:
		var shake_amount: float = deg_to_rad(shake_walk_deg) * clampf(speed / 3.0, 0.0, 1.3) \
			+ deg_to_rad(shake_step_deg) * _step_pulse \
			+ deg_to_rad(shake_pant_deg) * pant
		if shake_amount > 0.0:
			var t: float = _shake_time * shake_frequency
			shake_pitch = _noise.get_noise_2d(t, 0.0) * shake_amount
			shake_yaw = _noise.get_noise_2d(0.0, t) * shake_amount
			shake_roll = _noise.get_noise_2d(t, t) * shake_amount
			var pos_scale: float = shake_position * clampf(shake_amount / maxf(deg_to_rad(shake_walk_deg), 0.0001), 0.0, 3.0)
			shake_pos = Vector3(_noise.get_noise_2d(t, 17.0), _noise.get_noise_2d(31.0, t), 0.0) * pos_scale

	position = _base_position + _sway_offset \
		+ Vector3(_bob_x, _breath_y, 0.0) + _kick_offset \
		+ Vector3(0.0, _crouch_offset, 0.0) + shake_pos
	rotation = _base_rotation + Vector3(
		_drag_pitch_offset + shake_pitch + _accel_pitch + _kick_pitch,
		_drag_yaw_offset + shake_yaw,
		_lean_roll + _turn_roll + _breath_roll + _kick_roll + shake_roll)

	if fov_enabled:
		var target_fov: float = _base_fov
		if fps_movement:
			if fps_movement.CROUCHED:
				target_fov += crouch_fov_penalty
			elif Input.is_action_pressed("move_run") and speed > 0.5:
				target_fov += run_fov_bonus
		fov = lerpf(fov, target_fov, clampf(fov_speed * delta, 0.0, 1.0))

func _on_stepped() -> void:
	_step_pulse = 1.0
	if not impact_enabled:
		return
	_kick_velocity.y -= step_dip
	_kick_pitch_velocity -= deg_to_rad(step_pitch)

func _on_landed(impact: float) -> void:
	if not impact_enabled:
		return
	var strength: float = clampf(impact / 7.0, 0.0, 1.5)
	if strength <= 0.0:
		return
	_kick_velocity.y -= impact_impulse * strength
	_kick_pitch_velocity -= deg_to_rad(step_pitch) * strength * 2.0
	_kick_roll_velocity += randf_range(-1.0, 1.0) * impact_impulse * strength * 2.0
	_step_pulse = maxf(_step_pulse, strength)
