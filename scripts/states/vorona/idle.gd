extends State

@export var gravity: float = 9.8
@export var anim_tree: AnimationTree = null
@export var blend_weight: float = 0.05

@onready var cbody: CharacterBody3D = $"../.."
@onready var cbody_player: CharacterBody3D = $"../../../player_fps"

@onready var walk_val: float = 0.0

func enter() -> void:
	walk_val = anim_tree["parameters/Walk/blend_amount"]
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	float(delta)
	pass

func physics_update(delta: float) -> void:
	walk_val = lerpf(walk_val, 0.0, blend_weight)
	update_anim_tree()
	
	if cbody_player.global_position.distance_to(cbody.global_position) <= 5.0:
		Transitioned.emit("walking", self)
	
	if !cbody.is_on_floor():
		cbody.velocity.y -= gravity

func update_anim_tree() -> void:
	anim_tree["parameters/Walk/blend_amount"] = walk_val
