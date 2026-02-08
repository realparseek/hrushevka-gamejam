extends State

@onready var cam_anim_player: AnimationPlayer = $"../../head/camera/AnimationPlayer"

func enter() -> void:
	cam_anim_player.play("shaking2")

func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	if !cam_anim_player.is_playing():
		cam_anim_player.play("shaking2", -1, 1.5)

func physics_update(_delta: float) -> void:
	pass
