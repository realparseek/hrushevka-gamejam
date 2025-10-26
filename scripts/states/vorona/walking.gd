extends State

@export var agent: NavigationAgent3D = null
@export var move_speed: float = 1.0
@export var gravity: float = 9.8
@export var anim_tree: AnimationTree = null
@export var target3d: Vector3 = Vector3.ZERO
@export var blend_weight: float = 0.05

@onready var cbody: CharacterBody3D = $"../.."
@onready var cbody_player: CharacterBody3D = $"../../../player_fps"
@onready var walk_val: float = 0.0

func enter() -> void:
	agent.target_position = target3d
	walk_val = anim_tree["parameters/Walk/blend_amount"]
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	float(delta)
	pass

func physics_update(delta: float) -> void:
	walk_val = lerpf(walk_val, 1.0, blend_weight)
	update_anim_tree()
	
	agent.target_position = cbody_player.global_position
	if agent.is_target_reached():
		return
	
	var nextp: Vector3 = agent.get_next_path_position()
	if nextp != cbody.global_position:
		var pos2d: Vector2 = Vector2(cbody.global_position.x, cbody.global_position.z)
		var player_pos2d: Vector2 = Vector2(nextp.x, nextp.z)
		var dir: Vector2 = -(pos2d - player_pos2d)
		cbody.rotation.y = lerp_angle(cbody.rotation.y, atan2(dir.x, dir.y), blend_weight)
	
	cbody.velocity = (Vector3(nextp.x, 0.0, nextp.z) - cbody.position).normalized() * move_speed
	cbody.move_and_slide()

func update_anim_tree() -> void:
	anim_tree["parameters/Walk/blend_amount"] = walk_val
