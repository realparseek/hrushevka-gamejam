extends CharacterBody3D

@export var look_sensetivity : float = 6
@export var walk_speed : float = 10.0
@export var sprint_speed : float = 15.0
@export var gravity : float = 9.8
@export var headbob_size : float = 0.1
@export var headbob_speed : float = 1.25

var headbob_timer : float = 0.0
var look_sensetivity_mul : float = 0.001

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	_handle_headbob(delta)
	
func _physics_process(delta: float) -> void:
	_handle_ground_movement()
	_handle_gravity()

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed('ui_cancel'):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
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

func _handle_headbob(delta: float) -> void:
	if is_on_floor():
		$head.position.y = sin(headbob_timer)*headbob_size
		headbob_timer += delta*headbob_speed*velocity.length()

func _get_move_speed() -> float:
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	else:
		return walk_speed
