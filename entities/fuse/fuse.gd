extends Node

@export var rigid_body: RigidBody3D
@export var audio_player: SpatialAudioPlayer3D
@export var main_hit_sound: AudioStream
@export var other_hit_sounds: Array[AudioStream]   

func _ready():
	var parent = get_parent()
	if parent is RigidBody3D:
		parent.body_entered.connect(_on_body_entered)
	
	rigid_body.linear_velocity = Vector3(0.0, 0.0, 2.0)

func _on_body_entered(_body: Node):
	play_hit_sound()  

func play_hit_sound():
	var stream_to_play: AudioStream
	
	#if hit_count == 1:
		#stream_to_play = first_hit_sound
	#else:
	if other_hit_sounds.size() > 0:
		var random_index = randi() % other_hit_sounds.size()
		stream_to_play = other_hit_sounds[random_index]
	else:
		stream_to_play = main_hit_sound
		push_warning("other_hit_sounds пуст")
	
	if stream_to_play and audio_player:
		if audio_player.playing:
			audio_player.stop()   
		audio_player.stream = stream_to_play
		audio_player.play()
