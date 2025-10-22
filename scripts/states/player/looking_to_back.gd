extends State

@export var player_looking_state: Node = null
@export var turn_left: Area2D = null

@onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"

func _ready() -> void:
	turn_left.mouse_entered.connect(look_to_right)

func enter() -> void:
	player_looking_state.current_looking_state = LookingState.LookingStateEnum.LOOKING_TO_BACK
	anim_player.play("from_right_to_back", -1, 2)
	turn_left.visible = true

func exit() -> void:
	turn_left.visible = false

func look_to_right() -> void:
	if !anim_player.is_playing():
		Transitioned.emit("lookingtoright", self)
