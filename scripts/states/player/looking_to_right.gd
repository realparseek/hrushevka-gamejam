extends State

@export var player_looking_state: Node = null
@export var turn_left: Area2D = null
@export var turn_right: Area2D = null

@onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"

func _ready() -> void:
	turn_left.mouse_entered.connect(look_to_front)
	turn_right.mouse_entered.connect(look_to_back)
	
func enter() -> void:
	if player_looking_state.current_looking_state == LookingState.LookingStateEnum.LOOKING_TO_FRONT:
		anim_player.play("from_front_to_right", -1, 1.75)
	elif player_looking_state.current_looking_state == LookingState.LookingStateEnum.LOOKING_TO_BACK:
		anim_player.play("from_back_to_right", -1, 2)
	
	player_looking_state.current_looking_state = LookingState.LookingStateEnum.LOOKING_TO_RIGHT
	turn_left.visible = true
	turn_right.visible = true

func exit() -> void:
	turn_left.visible = false
	turn_right.visible = false
	
func look_to_front() -> void:
	if !anim_player.is_playing():
		Transitioned.emit("lookingtofront", self)
		
func look_to_back() -> void:
	if !anim_player.is_playing():
		Transitioned.emit("lookingtoback", self)
