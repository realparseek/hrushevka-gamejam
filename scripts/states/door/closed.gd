extends State
@export var audio_player: RaytracedAudioPlayer3D = null
@export var anim_player: AnimationPlayer = null

@onready var close_sound: Resource = load('res://sound/door/close.ogg')

func enter() -> void:
	$"../..".collision_layer |= 1
	if audio_player:
		audio_player.stream = close_sound
		audio_player.play()
	if anim_player:
		anim_player.play('doorAction', -1, -1.8, true)
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
