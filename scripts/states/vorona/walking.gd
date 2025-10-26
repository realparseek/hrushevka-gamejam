extends State

@export var agent: NavigationAgent3D = null
@export var move_speed: float = 1.0
@export var gravity: float = 9.8
@export var anim_player: AnimationPlayer = null
@export var target3d: Vector3 = Vector3.ZERO

@onready var cbody: CharacterBody3D = $"../.."
@onready var cbody_player: CharacterBody3D = $"../../../player_fps"

func enter() -> void:
	agent.target_position = target3d
	
func exit() -> void:
	anim_player.stop()

func update(delta: float) -> void:
	float(delta)
	pass

func physics_update(delta: float) -> void:
	agent.target_position = cbody_player.global_position
	if agent.is_target_reached():
		anim_player.stop()
		return
		
	if !anim_player.is_playing():
		anim_player.play("walk")
	
	var nextp: Vector3 = agent.get_next_path_position()
	if nextp != cbody.global_position:
		cbody.look_at(nextp, Vector3.UP, true)
		cbody.rotation.x = 0.0
	
	cbody.velocity = (Vector3(nextp.x, 0.0, nextp.z) - cbody.position).normalized() * move_speed
	cbody.move_and_slide()
