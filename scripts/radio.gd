extends AudioStreamPlayer3D

# Массив с аудиофайлами
var tracks = [
	preload("res://sound/radio/Cuckoo.ogg"),
	preload("res://sound/radio/Summer_will_be_over.ogg"),
	preload("res://sound/radio/commuter_train.ogg")
]

var current_track_index = 0
var radio_playing = false

func _ready():
	select_random_track()
	
	self.finished.connect(_on_track_finished)
	play_current_track()

func select_random_track():
	if tracks.size() > 0:
		current_track_index = randi() % tracks.size()

func _on_track_finished():
	# Автоматическое переключение на следующий трек
	current_track_index = (current_track_index + 1) % tracks.size()
	play_current_track()

func play_current_track():
	if tracks.size() > 0:
		self.stream = tracks[current_track_index]
		self.play()
		radio_playing = true
		print("Now playing track: ", current_track_index + 1)  # Для отладки

func play_next_track():
	current_track_index = (current_track_index + 1) % tracks.size()
	play_current_track()

func play_previous_track():
	current_track_index = (current_track_index - 1) % tracks.size()
	if current_track_index < 0:
		current_track_index = tracks.size() - 1
	play_current_track()

# Функция для принудительного случайного выбора
func play_random_track():
	select_random_track()
	play_current_track()

func toggle_play_pause():
	if radio_playing:
		self.stop()
		radio_playing = false
	else:
		self.play()
		radio_playing = true
