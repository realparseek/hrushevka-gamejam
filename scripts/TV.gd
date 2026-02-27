extends Node3D

@export var video_files : Array[VideoStream]
@export var audio_files : Array[AudioStream]
@export var use_raytraced_audio : bool = false
@export var video_size : Vector2i = Vector2i(1920, 1080)

@export var screen_mesh : MeshInstance3D
@export var audio_player : RaytracedAudioPlayer3D
@export var interaction_area : Area3D  # Зона, в которой можно переключать каналы

var current_index : int = 0
var video_player : VideoStreamPlayer
var viewport : SubViewport
var player_in_range : bool = false  # Флаг: игрок в зоне?

func _ready():
	if not screen_mesh:
		print("Ошибка: не назначен screen_mesh")
		return
	if not interaction_area:
		print("Ошибка: не назначена interaction_area")
		return

	# Подключаем сигналы области
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

	# Создаём Viewport
	viewport = SubViewport.new()
	viewport.name = "VideoViewport"
	viewport.size = video_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	add_child(viewport)

	# Создаём VideoStreamPlayer
	video_player = VideoStreamPlayer.new()
	video_player.name = "VideoPlayer"
	video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video_player.expand = true
	video_player.size = Vector2(video_size.x, video_size.y)
	video_player.position = Vector2(0, 0)
	viewport.add_child(video_player)

	# Подключаем сигнал окончания видео
	video_player.finished.connect(_on_video_finished)

	# Материал
	var material = StandardMaterial3D.new()
	material.albedo_texture = viewport.get_texture()
	screen_mesh.material_override = material

	# Запускаем первый ролик
	play_channel(current_index)

func play_channel(index: int):
	if index < 0 or index >= video_files.size():
		return

	video_player.stop()
	if use_raytraced_audio and audio_player:
		audio_player.stop()

	video_player.stream = video_files[index]
	video_player.play()

	if use_raytraced_audio and audio_player and index < audio_files.size():
		audio_player.stream = audio_files[index]
		audio_player.play()
		video_player.volume_db = -80   # отключаем встроенный звук
	else:
		video_player.volume_db = 0

	current_index = index

func _on_video_finished():
	var next_index = (current_index + 1) % video_files.size()
	play_channel(next_index)

func _process(_delta):
	# Переключение только если игрок в зоне И нажата клавиша
	if player_in_range and Input.is_action_just_pressed("interact"):
		var next_index = (current_index + 1) % video_files.size()
		play_channel(next_index)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
