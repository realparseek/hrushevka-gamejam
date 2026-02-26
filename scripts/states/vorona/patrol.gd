extends State

@export var agent: NavigationAgent3D = null
@export var move_speed: float = 1.0
@export var gravity: float = 9.8
@export var anim_tree: AnimationTree = null
@export var target3d: Vector3 = Vector3.ZERO
@export var blend_weight: float = 0.05
@export var patrol_points: Array[Node3D] = []

@onready var cbody: CharacterBody3D = $"../.."
@onready var walk_val: float = 0.0

func enter() -> void:
	agent.target_position = target3d
	walk_val = 0.0
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if agent.is_target_reached():
		walk_val = lerpf(walk_val, 0.0, blend_weight)
		update_anim_tree()
		return
	
	walk_val = lerpf(walk_val, 1.0, blend_weight)
	update_anim_tree()

	agent.target_position = patrol_points[0].global_position

	var next_pos: Vector3 = agent.get_next_path_position()
	var direction: Vector3 = (next_pos - cbody.global_position).normalized()
	direction.y = 0

	if direction.length() > 0:
		var target_angle: float = atan2(direction.x, direction.z)
		cbody.rotation.y = lerp_angle(cbody.rotation.y, target_angle, blend_weight)

	cbody.velocity.x = direction.x * move_speed
	cbody.velocity.z = direction.z * move_speed

	#if not cbody.is_on_floor():
		#cbody.velocity.y -= gravity * delta

	cbody.move_and_slide()

func update_anim_tree() -> void:
	anim_tree["parameters/Walk/blend_amount"] = walk_val
