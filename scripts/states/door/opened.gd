extends State
@export var audio_player: RaytracedAudioPlayer3D = null
@export var anim_player: AnimationPlayer = null

@onready var open_sound: Resource = load('res://sound/door/open.ogg')

func enter() -> void:
	$"../..".collision_layer &= ~(1)
	if audio_player:
		audio_player.play()
	if anim_player:
		audio_player.stream = open_sound
		audio_player.play()
		anim_player.play('doorAction', -1, 0.5)
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
