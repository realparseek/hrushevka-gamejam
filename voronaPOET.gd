extends Node

@export var audio_player: SteamAudioPlayer
@export var track_length: float = 1132.0  
@export var min_end_buffer: float = 60.0  

func _ready():
	
	if audio_player == null:
		audio_player = get_node("vorona/SteamAudioPlayer")  
	
  
	start_random_playback()

func start_random_playback():
	if audio_player == null or audio_player.stream == null:
		push_error("поток не назначен!")
		return
	

	var max_start_time = track_length - min_end_buffer
	
   
	if max_start_time <= 0:
		push_error("Трек слишком короткий для заданного буфера!")
		audio_player.play()
		return
	
	var random_start_time = randf_range(0.0, max_start_time)
	
  
	audio_player.play(random_start_time)
	print("Начинаем воспроизведение с ", random_start_time, " секунды")

func restart_random():
	if audio_player.playing:
		audio_player.stop()
	start_random_playback()


func _on_audio_stream_player_finished():
   
	start_random_playback()
