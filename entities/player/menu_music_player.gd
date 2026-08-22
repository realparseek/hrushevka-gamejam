extends AudioStreamPlayer2D

@export var pause_menu_node: Control = null

var saved_position: float = 0.0

func _ready():
	if pause_menu_node == null:
		return
	
	pause_menu_node.visibility_changed.connect(_on_pause_menu_visibility_changed)
	finished.connect(_on_music_finished)

func _on_pause_menu_visibility_changed():
	if pause_menu_node.visible:
		if not playing:
			play(saved_position)
		else:
			stream_paused = false
	else:
		if playing:
			saved_position = get_playback_position()
			stream_paused = true

func _on_music_finished():
	if playing:
		play(0.0)
