extends State

@onready var cam_anim_player: AnimationPlayer = $"../../Camera3D/AnimationPlayer"
@onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"

func enter() -> void:
	cam_anim_player.play("shaking2")

func exit() -> void:
	pass
	
func update(delta: float) -> void:
	if !cam_anim_player.is_playing():
		cam_anim_player.play("shaking2", -1, 1.5)

func physics_update(delta: float) -> void:
	pass
