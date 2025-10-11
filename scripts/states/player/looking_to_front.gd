extends State

@export var player_looking_state: Node = null
@export var turn_right: Area2D = null

@onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"

func _ready() -> void:
	turn_right.mouse_entered.connect(look_to_right)

func enter() -> void:
	player_looking_state.current_looking_state = LookingState.LookingStateEnum.LOOKING_TO_FRONT
	anim_player.play("from_right_to_front", -1, 1.75)
	turn_right.visible = true

func exit() -> void:
	turn_right.visible = false

func look_to_right() -> void:
	if !anim_player.is_playing():
		Transitioned.emit("lookingtoright", self)
