extends Node
class_name FPSMovement

@export var pause_menu: PauseMenu
@export var player: CharacterBody3D
@export var head: Node3D
@export var steps_player: SpatialAudioPlayer3D
@export var step_sounds: Array[AudioStream]
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

@export var push_force_walk: float = 8.0
@export var push_force_run: float = 15.0
@export var max_push_impulse: float = 50.0
@export var push_mass_scale: float = 0.8
@export var max_ball_horizontal_speed: float = 5.0
@export var ball_damping: float = 0.98
@export var side_push_strength: float = 8.0
@export var ball_side_scale: float = 0.5
@export var max_side_push_speed: float = 2.0

@export var heavy_push_threshold: float = 5.0
@export var heavy_push_max_mass: float = 50.0
@export var push_mass_exponent: float = 0.7
@export var push_slowdown_factor: float = 0.3
@export var freeze_radius: float = 0.6

@export var top_push_factor: float = 0.5
@export var max_object_horiz_speed: float = 3.0

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

var _floor_collider: Node = null
var _was_on_floor: bool = false
var _frozen_objects: Array = []

func _ready() -> void:
	HEADBOB_START_Y = head.position.y
	HEADBOB_START_ROT_Z = head.rotation.z
	PLAYER_START_HEIGHT = collision_shape.shape.height
	player.floor_max_angle = 0.7

func _physics_process(delta: float) -> void:
	_handle_pausing()
	if pause_menu and pause_menu.PAUSED: return
	
	_handle_gravity(delta)
	_handle_jump()
	_handle_walk()
	_handle_step_sounds()
	_handle_headbob(delta)
	_handle_crouching()

	_was_on_floor = player.is_on_floor()
	player.move_and_slide()
	
	var floor_col = player.get_last_slide_collision()
	if floor_col and player.is_on_floor() and floor_col.get_normal().y > 0.9:
		_floor_collider = floor_col.get_collider()
	else:
		_floor_collider = null
	
	if player.is_on_floor():
		_update_frozen_objects()
		_process_rigidbody_collisions()
	else:
		for rb in _frozen_objects.duplicate():
			rb.freeze = false
			_frozen_objects.erase(rb)
	
	if player.is_on_floor() and player.velocity.y > 0:
		player.velocity.y = 0

func _process_rigidbody_collisions() -> void:
	var processed = []
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		var collider = collision.get_collider()
		if not (collider is RigidBody3D):
			continue
		var rb = collider as RigidBody3D
		if collider in processed:
			continue
		processed.append(collider)
		
		if rb == _floor_collider:
			continue
		
		var normal = collision.get_normal()
		var is_top = (abs(normal.y) > 0.9) and player.is_on_floor()
		var is_side = abs(normal.y) < 0.9
		
		var is_ball = rb.is_in_group("ball")
		var is_long = rb.is_in_group("long_object")
		var mass = rb.mass
		
		var is_running = Input.is_action_pressed("move_run")
		var can_push = false
		if is_ball or is_long:
			can_push = true
		else:
			if mass <= heavy_push_threshold or is_running:
				can_push = true
		
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var move_dir = Vector3.ZERO
		var is_moving = false
		if input_dir.length() > 0.01:
			move_dir = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			is_moving = true
		
		var just_landed = (player.is_on_floor() and not _was_on_floor)
		
		if is_top and is_moving and not just_landed:
			pass
		
		elif is_side and is_moving and player.is_on_floor():
			if not can_push:
				continue
			
			var push_dir = move_dir
			var normal_horiz = Vector3(normal.x, 0, normal.z).normalized()
			if normal_horiz.length() > 0.1:
				push_dir = (move_dir + normal_horiz * 0.3).normalized()
			
			var mass_factor = 1.0 / pow(1.0 + mass * push_mass_scale, push_mass_exponent)
			var impulse_magnitude = side_push_strength * mass_factor
			if is_ball:
				impulse_magnitude *= ball_side_scale
			
			var contact_point = collision.get_position()
			var offset = contact_point - rb.global_position
			rb.apply_impulse(push_dir * impulse_magnitude, offset)
			
			if not is_long:
				var horiz_vel = Vector2(rb.linear_velocity.x, rb.linear_velocity.z)
				if horiz_vel.length() > max_side_push_speed:
					horiz_vel = horiz_vel.normalized() * max_side_push_speed
					rb.linear_velocity.x = horiz_vel.x
					rb.linear_velocity.z = horiz_vel.y
			
			var player_push = -normal_horiz * 0.2
			player.velocity.x += player_push.x
			player.velocity.z += player_push.z
			
			if not is_ball and mass > heavy_push_threshold and not is_long:
				var slowdown = clamp(mass / heavy_push_max_mass, 0.0, 1.0) * push_slowdown_factor * 0.5
				player.velocity.x = lerp(player.velocity.x, player.velocity.x * (1.0 - slowdown), 0.5)
				player.velocity.z = lerp(player.velocity.z, player.velocity.z * (1.0 - slowdown), 0.5)

func _update_frozen_objects() -> void:
	if not player:
		return
		
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var found_heavy = []
	
	if _floor_collider is RigidBody3D:
		var rb = _floor_collider as RigidBody3D
		var is_ball = rb.is_in_group("ball")
		var is_long = rb.is_in_group("long_object")
		if not is_ball and not is_long:
			found_heavy.append(rb)
			if not rb.freeze:
				rb.freeze = true
				rb.linear_velocity = Vector3.ZERO
				rb.angular_velocity = Vector3.ZERO
				if rb not in _frozen_objects:
					_frozen_objects.append(rb)
	
	if input_vector.length() > 0.01:
		var space_state = player.get_world_3d().direct_space_state
		var query = PhysicsShapeQueryParameters3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = freeze_radius
		query.shape = sphere
		query.transform = player.global_transform
		query.collide_with_bodies = true
		query.collide_with_areas = false
		
		var results = space_state.intersect_shape(query)
		
		for result in results:
			var collider = result.collider
			if collider is RigidBody3D:
				var rb = collider as RigidBody3D
				if rb == _floor_collider:
					continue
				var is_ball = rb.is_in_group("ball")
				var is_long = rb.is_in_group("long_object")
				if is_ball or is_long:
					continue
				var mass = rb.mass
				if mass > heavy_push_threshold:
					if rb.linear_velocity.y < -0.5:
						continue
						
					found_heavy.append(rb)
					var is_running = Input.is_action_pressed("move_run")
					var should_freeze = (mass > heavy_push_max_mass) or (not is_running)
					if should_freeze:
						if not rb.freeze:
							rb.freeze = true
							rb.linear_velocity = Vector3.ZERO
							rb.angular_velocity = Vector3.ZERO
							if rb not in _frozen_objects:
								_frozen_objects.append(rb)
					else:
						if rb.freeze:
							rb.freeze = false
							rb.linear_velocity = Vector3.ZERO
							rb.angular_velocity = Vector3.ZERO
						if rb in _frozen_objects:
							_frozen_objects.erase(rb)
	
	for rb in _frozen_objects.duplicate():
		if rb not in found_heavy:
			rb.freeze = false
			_frozen_objects.erase(rb)

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
	var speed: float = move_speed
	if not CROUCHED and Input.is_action_pressed("move_run"):
		speed = run_speed
	player.velocity.x = lerp(player.velocity.x, direction.x * speed, move_acceleration)
	player.velocity.z = lerp(player.velocity.z, direction.z * speed, move_acceleration)

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
	collision_shape.shape.height = lerp(collision_shape.shape.height, desired_height, crouch_acceleration)

func _handle_pausing():
	if not pause_menu: return
	if Input.is_action_just_pressed("ui_pause"):
		if pause_menu.PAUSED:
			pause_menu.unpause()
		else:
			pause_menu.pause()

func _play_step_sound() -> void:
	steps_player.stream = step_sounds[NEXT_STEP_SOUND]
	steps_player.play()
	NEXT_STEP_SOUND = wrap(NEXT_STEP_SOUND+1, 0, step_sounds.size())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(event.relative.x * -mouse_sensetivity * SENSETIVITY_MUL)
		HEAD_PITCH += event.relative.y * -mouse_sensetivity * SENSETIVITY_MUL
		HEAD_PITCH = clamp(HEAD_PITCH, deg_to_rad(-90), deg_to_rad(90))
		head.rotation.x = HEAD_PITCH
