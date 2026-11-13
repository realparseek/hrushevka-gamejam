extends Node
class_name PauseMenu

@export var menu: ColorRect
@export var menu_container: VBoxContainer
@export var resume_button: Button
@export var settings_button: Button
@export var exit_button: Button
@export var ambient: AudioStreamPlayer
@export var settings_panel: Panel
@export var fps_slider: HSlider
@export var fps_value_label: Label
@export var volume_slider: HSlider
@export var volume_value_label: Label
@export var back_button: Button
@export var save_button: Button
@export var load_button: Button
@export var reset_button: Button
@export var scene_loader: SceneLoader
@export var inventory: Inventory

var PAUSED: bool = false
var AMBIENTPOS: float = 0.0
var _save_system: SaveSystem = null


func _ready() -> void:
	_save_system = get_node("/root/SaveSystem") as SaveSystem
	if resume_button: resume_button.connect("pressed", _on_resume_btn_press)
	if settings_button: 
		settings_button.connect("pressed", _on_settings_btn_press)
	if exit_button: exit_button.connect("pressed", _on_exit_btn_press)
	if back_button: back_button.connect("pressed", _on_back_btn_press)
	if save_button: save_button.connect("pressed", _on_save_btn_press)
	if load_button: load_button.connect("pressed", _on_load_btn_press)
	if reset_button: reset_button.connect("pressed", _on_reset_btn_press)
	if fps_slider: fps_slider.value_changed.connect(_on_fps_changed)
	if volume_slider: volume_slider.value_changed.connect(_on_volume_changed)
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	if settings_panel: settings_panel.visible = false
	if menu_container: menu_container.visible = PAUSED
	menu.visible = PAUSED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if PAUSED else Input.MOUSE_MODE_CAPTURED)
	Engine.max_fps = int(fps_slider.value) if fps_slider else 240
	_update_volume()

func _input(event: InputEvent) -> void:
	if not PAUSED:
		return
	if event is InputEventMouseButton and event.pressed:
		if settings_button and settings_button.get_global_rect().has_point(event.position):
			_on_settings_btn_press()
		elif back_button and back_button.get_global_rect().has_point(event.position) and settings_panel and settings_panel.visible:
			_on_back_btn_press()
		elif resume_button and resume_button.get_global_rect().has_point(event.position):
			_on_resume_btn_press()
		elif exit_button and exit_button.get_global_rect().has_point(event.position):
			_on_exit_btn_press()
		elif save_button and save_button.get_global_rect().has_point(event.position):
			_on_save_btn_press()
		elif load_button and load_button.get_global_rect().has_point(event.position):
			_on_load_btn_press()
		elif reset_button and reset_button.get_global_rect().has_point(event.position):
			_on_reset_btn_press()

func pause() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu.visible = true
	if menu_container:
		menu_container.visible = true
	if settings_panel:
		settings_panel.visible = false
	
	if ambient:
		ambient.play(AMBIENTPOS)
		PAUSED = true

func unpause() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.visible = false
	if menu_container:
		menu_container.visible = false
	if settings_panel:
		settings_panel.visible = false
	AMBIENTPOS = ambient.get_playback_position()
	PAUSED = false
	
	if ambient: ambient.stop()

func _on_resume_btn_press() -> void:
	unpause()

func _on_exit_btn_press() -> void:
	get_tree().quit()

func _on_settings_btn_press() -> void:
	if settings_panel:
		settings_panel.visible = true
	if menu_container:
		menu_container.visible = false

func _on_back_btn_press() -> void:
	if settings_panel:
		settings_panel.visible = false
	if menu_container:
		menu_container.visible = true


func _on_save_btn_press() -> void:
	if not _save_system: return
	if not scene_loader or not scene_loader.CURRENT_SCENE: return
	var path := scene_loader._current_scene_path
	if path.is_empty(): return
	_save_system.snapshot_level(path, scene_loader.CURRENT_SCENE)
	if inventory:
		_save_system.snapshot_inventory(inventory)
	_save_system.player_transform = _player_transform()
	_save_system.player_level_path = path
	var ok := _save_system.save_game()
	print("Save: ", "OK" if ok else "FAILED")


func _on_load_btn_press() -> void:
	if not _save_system: return
	if not _save_system.has_save():
		print("Load: no save found")
		return
	if not _save_system.load_game():
		print("Load: failed to parse save")
		return
	if scene_loader and scene_loader.CURRENT_SCENE:
		var path := scene_loader._current_scene_path
		_save_system.tag_entities(scene_loader.CURRENT_SCENE)
		_save_system.apply_level_state(path, scene_loader.CURRENT_SCENE)
	if inventory:
		_save_system.apply_inventory(inventory, _save_system.inventory_items)
	_apply_player_transform()
	print("Load: OK")


func _on_reset_btn_press() -> void:
	if not _save_system: return
	_save_system.reset_all()
	if scene_loader and scene_loader.CURRENT_SCENE:
		var path := scene_loader._current_scene_path
		if not path.is_empty():
			scene_loader.SKIP_SNAPSHOT = true
			scene_loader.load_scene(path)
	if inventory:
		for slot in inventory.get_slots():
			slot.set_item(null)
	print("Reset: OK")


func _player_transform() -> Transform3D:
	var player := get_parent() as CharacterBody3D
	if player:
		return player.global_transform
	return Transform3D.IDENTITY


func _apply_player_transform() -> void:
	if not _save_system or not scene_loader: return
	var saved_level := _save_system.player_level_path
	var current_level := scene_loader._current_scene_path
	if saved_level != "" and saved_level != current_level:
		scene_loader.TELEPORT_TO_SAVE = true
		scene_loader.load_scene(saved_level)
		return
	var player := get_parent() as CharacterBody3D
	if player and _save_system.player_transform != Transform3D.IDENTITY:
		player.global_transform = _save_system.player_transform

func _on_fps_changed(value: float) -> void:
	Engine.max_fps = int(value)
	if fps_value_label:
		fps_value_label.text = str(int(value))

func _on_volume_changed(value: float) -> void:
	if volume_value_label:
		volume_value_label.text = str(int(value)) + "%"
	_update_volume()

func _update_volume() -> void:
	if volume_slider:
		var vol: float = volume_slider.value / 100.0
		var master_bus: int = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(vol))
