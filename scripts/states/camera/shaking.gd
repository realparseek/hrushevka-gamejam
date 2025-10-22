extends State

@onready var cam_anim_player: AnimationPlayer = $"../../head/Camera3D/AnimationPlayer"

func enter() -> void:
	cam_anim_player.play("shaking2")

func exit() -> void:
	pass
	
func update(delta: float) -> void:
	if !cam_anim_player.is_playing():
		cam_anim_player.play("shaking2", -1, 1.5)

func physics_update(delta: float) -> void:
	pass
