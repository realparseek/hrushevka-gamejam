extends CharacterBody3D

@export var look_sensetivity : float = 6
@export var walk_speed : float = 1.3
@export var sprint_speed : float = 2.0
@export var crouch_speed : float = 0.8
@export var gravity : float = 9.8
@export var headbob_size : float = 0.05
@export var headbob_speed : float = 5.0
@export var walk_audio : RaytracedAudioPlayer3D = null

var headbob_timer : float = 0.0
var look_sensetivity_mul : float = 0.001
var head_init_pos : Vector3 = Vector3.ZERO
var camera_init_pos : Vector3 = Vector3.ZERO
var prev_head_y : float = 0.0
var walk_sounds : Array[Resource]
var cur_walk_sound : int = 0
var walk_sound_played : bool = false
var can_walk : bool = false
var crouching : bool = false
var crouching_size : float = 1.0

func _ready() -> void:
	add_to_group("player")
	head_init_pos = Vector3($head.position)
	camera_init_pos = Vector3($head/camera.position)
	walk_sounds.append(load("res://sound/walk/walk_concrete1.ogg"))
	walk_sounds.append(load("res://sound/walk/walk_concrete2.ogg"))
	walk_sounds.append(load("res://sound/walk/walk_concrete3.ogg"))
	walk_sounds.append(load("res://sound/walk/walk_concrete4.ogg"))
	
func _process(delta: float) -> void:
	_handle_headbob(delta)
	_handle_crouching(delta)
	
func _physics_process(_delta: float) -> void:
	if not can_walk:
		if get_parent().scenes_loaded.size() >= 2:
			can_walk = true
		else:
			return
	_handle_ground_movement()
	_handle_gravity()

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed('ui_cancel'):
		if event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x*look_sensetivity*look_sensetivity_mul)
			$head.rotate_x(-event.relative.y*look_sensetivity*look_sensetivity_mul)
			$head.rotation.x = clamp($head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _handle_ground_movement() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var wdir = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward").normalized()
		wdir = global_transform.basis * Vector3(wdir.x, 0.0, wdir.y)
		velocity = wdir*_get_move_speed()
	else:
		velocity = Vector3.ZERO

func _handle_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity
	else:
		velocity.y = 0.0

func _handle_crouching(delta: float) -> void:
	if Input.is_action_just_pressed('crouch'):
		crouching = !crouching
	$head.position.y = lerp($head.position.y, ((head_init_pos.y-crouching_size) if crouching else head_init_pos.y), delta*3)

func _handle_headbob(delta: float) -> void:
	if is_on_floor():
		#$head.position.y = head_init_pos.y+sin(headbob_timer)*headbob_size
		$head/camera.position.y = camera_init_pos.y+sin(headbob_timer)*headbob_size
		if sin(headbob_timer) <= -0.95:
			if not walk_sound_played:
				_play_random_walk_sound()
				walk_sound_played = true
		else:
			walk_sound_played = false
			
		headbob_timer += delta*headbob_speed*velocity.length()

func _get_move_speed() -> float:
	if Input.is_action_pressed("sprint") and not crouching:
		return sprint_speed
	elif crouching:
		return crouch_speed
	else:
		return walk_speed

func _play_random_walk_sound() -> void:
	#if not walk_audio.playing:
	
	walk_audio.stream = walk_sounds[cur_walk_sound]
	if crouching:
		walk_audio.volume_db = -40
	elif Input.is_action_pressed('sprint'):
		walk_audio.volume_db = -15
	else:
		walk_audio.volume_db = -20
	walk_audio.play()
	print(walk_audio.volume_db)
	cur_walk_sound = wrap(cur_walk_sound+1, 0, 4)
