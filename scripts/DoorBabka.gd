extends Node3D

@export var door_sounds : Array[AudioStream]
@export var interaction_area : Area3D
@export var audio_player : RaytracedAudioPlayer3D

var player_in_range := false
var current_sound_index := 0

func _ready():
	if not interaction_area or not audio_player:
		return
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if audio_player and door_sounds.size() > 0:
			audio_player.stream = door_sounds[current_sound_index]
			audio_player.play()
			current_sound_index += 1
			if current_sound_index >= door_sounds.size():
				current_sound_index = 0  

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
