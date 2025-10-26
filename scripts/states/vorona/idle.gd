extends State

@export var gravity: float = 9.8
@export var anim_player: AnimationPlayer = null

@onready var cbody: CharacterBody3D = $"../.."
@onready var cbody_player: CharacterBody3D = $"../../../player_fps"

func enter() -> void:
	pass
	
func exit() -> void:
	anim_player.stop()

func update(delta: float) -> void:
	float(delta)
	pass

func physics_update(delta: float) -> void:
	if cbody_player.global_position.distance_to(cbody.global_position) <= 5.0:
		Transitioned.emit("walking", self)
	
	if !anim_player.is_playing():
		anim_player.play("idle")
	
	if !cbody.is_on_floor():
		cbody.velocity.y -= gravity
