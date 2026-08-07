extends Node
class_name FPSMovement

@export var player: CharacterBody3D
@export var head: Node3D
@export var steps_player: SpatialAudioPlayer3D
@export var collision_shape: CollisionShape3D
@export var move_speed: float = 2.0
@export var run_speed: float = 3.0
@export var move_acceleration: float = 0.2
@export var crouch_size: float = 1.2
@export var crouch_acceleration: float = 0.07
@export var jump_force: float = 6.0
@export var mouse_sensetivity: float = 3.0
@export var headbob_size: float = 0.07
@export var headbob_speed: float = 3.5
@export var headbob_tilt: float = 0.7
@export var crouch_tilt: float = 2.0

const SENSETIVITY_MUL: float = 0.001
var HEADBOB_START_Y: float = 0.0
var HEADBOB_START_ROT_Z: float = 0.0
var HEADBOB_VAL: float = 0.0
var HEADBOB_PREV_DIR: float = 0.0
var HEADBOB_CUR_DIR: float = 0.0
var HEAD_PITCH: float = 0.0
var PLAYER_START_HEIGHT: float = 0.0
var STEP_SOUND_PLAYED: bool = false
var NEXT_STEP_SOUND: int = 0
var CROUCHED: bool = false

var step_sounds: Array[AudioStream] = [
	preload("res://assets/audio/steps/step0.ogg"),
	preload("res://assets/audio/steps/step1.ogg"),
	preload("res://assets/audio/steps/step2.ogg"),
	preload("res://assets/audio/steps/step3.ogg"),
	preload("res://assets/audio/steps/step4.ogg"),
	preload("res://assets/audio/steps/step5.ogg")]

func _ready() -> void:
	HEADBOB_START_Y = head.position.y
	HEADBOB_START_ROT_Z = head.rotation.z
	PLAYER_START_HEIGHT = collision_shape.shape.height

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_jump()
	_handle_walk()
	_handle_step_sounds()
	_handle_headbob(delta)
	_handle_crouching()

	player.move_and_slide()

func _handle_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * 2.0 * delta

func _handle_jump() -> void:
	if Input.is_action_just_pressed("move_jump") and player.is_on_floor():
		player.velocity.y = jump_force
		_play_step_sound()
		HEADBOB_VAL = 0.0
	
func _handle_walk() -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed: float = move_speed if not Input.is_action_pressed("move_run") else run_speed
	player.velocity.x = lerpf(player.velocity.x, direction.x * speed, move_acceleration) 
	player.velocity.z = lerpf(player.velocity.z, direction.z * speed, move_acceleration)

func _handle_headbob(delta: float) -> void:
	HEADBOB_VAL += delta * headbob_speed * player.velocity.length()
	HEADBOB_PREV_DIR = HEADBOB_CUR_DIR
	HEADBOB_CUR_DIR = sin(HEADBOB_VAL) * headbob_size
	head.position.y = HEADBOB_START_Y + HEADBOB_CUR_DIR
	var tilt: float = deg_to_rad(headbob_tilt) if not CROUCHED else deg_to_rad(crouch_tilt)
	
	head.rotation.z = HEADBOB_START_ROT_Z + tilt * (cos(HEADBOB_VAL/2))

func _handle_step_sounds() -> void:
	if HEADBOB_PREV_DIR < HEADBOB_CUR_DIR and not STEP_SOUND_PLAYED and player.is_on_floor():
		_play_step_sound()
		STEP_SOUND_PLAYED = true
	
	if HEADBOB_PREV_DIR > HEADBOB_CUR_DIR and STEP_SOUND_PLAYED:
		STEP_SOUND_PLAYED = false

func _handle_crouching():
	if Input.is_action_just_pressed("move_crouch"):
		CROUCHED = not CROUCHED
	
	var desired_height: float = PLAYER_START_HEIGHT-crouch_size if CROUCHED else PLAYER_START_HEIGHT
	collision_shape.shape.height = lerpf(collision_shape.shape.height, desired_height, crouch_acceleration)

func _play_step_sound() -> void:
	steps_player.stream = step_sounds[NEXT_STEP_SOUND]
	steps_player.play()
	#print('Step sound player: ', NEXT_STEP_SOUND)
	NEXT_STEP_SOUND = wrap(NEXT_STEP_SOUND+1, 0, step_sounds.size())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(event.relative.x * -mouse_sensetivity * SENSETIVITY_MUL)
		HEAD_PITCH += event.relative.y * -mouse_sensetivity * SENSETIVITY_MUL
		HEAD_PITCH = clamp(HEAD_PITCH, deg_to_rad(-90), deg_to_rad(90))
		head.rotation.x = HEAD_PITCH
