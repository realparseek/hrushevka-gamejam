extends ColorRect
class_name BodycamAtmosphere

@export_subgroup("Ссылки")
@export var player: CharacterBody3D
@export var head: Node3D
@export var fps_movement: FPSMovement
@export var breathing: Breathing
@export var pause_menu: PauseMenu

@export_subgroup("Зерно")
@export var base_grain: float = 0.006
@export var speed_grain: float = 0.008
@export var pant_grain: float = 0.010

@export_subgroup("Хроматическая аберрация")
@export var base_chromatic: float = 0.0016
@export var turn_chromatic: float = 0.009
@export var pant_chromatic: float = 0.003

@export_subgroup("Дисторсия линзы")
@export var base_distortion: float = -0.08
@export var breath_distortion: float = 0.05
@export var impact_distortion: float = -0.06

@export_subgroup("Виньетка")
@export var base_vignette: float = 0.38
@export var sprint_vignette: float = 0.16
@export var pant_vignette: float = 0.20

@export_subgroup("Прочее")
@export var base_flicker: float = 0.02
@export var impact_flicker: float = 0.06
@export var pant_wobble: float = 0.004
@export var smoothing: float = 6.0

var _mat: ShaderMaterial
var _prev_yaw: float = 0.0
var _prev_pitch: float = 0.0
var _ang_speed: float = 0.0
var _impact: float = 0.0
var _breath_time: float = 0.0
var _grain: float
var _chromatic: float
var _distortion: float
var _vignette: float
var _flicker: float
var _wobble: float

func _ready() -> void:
	_mat = material as ShaderMaterial
	_grain = base_grain
	_chromatic = base_chromatic
	_distortion = base_distortion
	_vignette = base_vignette
	_flicker = base_flicker
	_wobble = 0.0
	if player:
		_prev_yaw = player.rotation.y
	if head:
		_prev_pitch = head.rotation.x
	if fps_movement and fps_movement.has_signal("landed"):
		fps_movement.landed.connect(_on_landed)

func _process(delta: float) -> void:
	if pause_menu and pause_menu.PAUSED:
		return
	if _mat == null or player == null or delta <= 0.0:
		return

	var speed: float = Vector2(player.velocity.x, player.velocity.z).length()

	var yaw: float = player.rotation.y
	var pitch: float = head.rotation.x if head else 0.0
	var d_yaw: float = wrapf(yaw - _prev_yaw, -PI, PI)
	var d_pitch: float = pitch - _prev_pitch
	_prev_yaw = yaw
	_prev_pitch = pitch
	var ang: float = sqrt(d_yaw * d_yaw + d_pitch * d_pitch) / delta
	_ang_speed = lerpf(_ang_speed, ang, clampf(delta * 10.0, 0.0, 1.0))
	_impact = lerpf(_impact, 0.0, clampf(delta * 4.0, 0.0, 1.0))

	var pant: float = breathing.PANT if breathing else 0.0
	var crouched: bool = fps_movement != null and fps_movement.CROUCHED
	var run_held: bool = Input.is_action_pressed("move_run") if fps_movement == null else fps_movement.RUNNING
	var sprinting: float = 0.0
	if run_held and not crouched and speed > 2.0:
		sprinting = clampf(speed - 2.0, 0.0, 1.0)

	_breath_time += delta * (1.0 + pant * 1.5)
	var breath_phase: float = 0.5 + 0.5 * sin(_breath_time * 1.5)

	var k: float = clampf(smoothing * delta, 0.0, 1.0)
	_grain = lerpf(_grain, base_grain + speed_grain * clampf(speed / 3.0, 0.0, 1.4) + pant_grain * pant, k)
	_chromatic = lerpf(_chromatic, base_chromatic + turn_chromatic * clampf(_ang_speed / 6.0, 0.0, 1.5) + pant_chromatic * pant, k)
	_distortion = lerpf(_distortion, base_distortion + breath_distortion * (breath_phase - 0.5) + impact_distortion * _impact, k)
	_vignette = lerpf(_vignette, base_vignette + sprint_vignette * sprinting + pant_vignette * pant + (1.0 - breathing.STAMINA) * 0.15, k)
	_flicker = lerpf(_flicker, base_flicker + impact_flicker * _impact, k)
	_wobble = lerpf(_wobble, pant_wobble * pant + _impact * 0.006, k)

	_mat.set_shader_parameter("grain_amount", _grain)
	_mat.set_shader_parameter("chromatic_amount", _chromatic)
	_mat.set_shader_parameter("distortion_amount", _distortion)
	_mat.set_shader_parameter("vignette_strength", _vignette)
	_mat.set_shader_parameter("flicker_amount", _flicker)
	_mat.set_shader_parameter("uv_wobble", _wobble)

func _on_landed(impact: float) -> void:
	_impact = minf(1.4, _impact + clampf(impact / 6.0, 0.2, 1.4))
