extends State

@export var light: OmniLight3D = null
@export var mesh_on: MeshInstance3D = null
@export var mesh_off: MeshInstance3D = null
@export var audio_player: SteamAudioPlayer = null

@onready var enter_blink_timer: float = 1.0

func enter() -> void:
	light.visible = true
	enter_blink_timer = 1.0
	if audio_player:
		audio_player.play()
	
func exit() -> void:
	mesh_on.visible = false

func update(delta: float) -> void:
	_handle_enter_blinking(delta)

func physics_update(delta: float) -> void:
	float(delta)
	pass

func _handle_enter_blinking(delta: float) -> void:
	if enter_blink_timer != 0.0:
		enter_blink_timer = max(enter_blink_timer-delta, 0.0)
	
	if enter_blink_timer > 0.85:
		mesh_on.visible = true
		mesh_off.visible = false
		light.light_energy = 1.0
	elif enter_blink_timer > 0.75:
		mesh_on.visible = false
		mesh_off.visible = true
		light.light_energy = 0.0
	elif enter_blink_timer > 0.25:
		mesh_on.visible = true
		mesh_off.visible = false
		light.light_energy = 0.7
	elif enter_blink_timer == 0.0:
		light.light_energy = lerpf(light.light_energy, 1.0, delta*3)
