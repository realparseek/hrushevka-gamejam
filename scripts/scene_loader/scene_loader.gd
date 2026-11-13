extends Node
class_name SceneLoader

@export var player: CharacterBody3D
@export var start_scene: PackedScene
@export var loading_screen: LoadingScreen

var CURRENT_SCENE: Node3D = null
var LOAD_REQUESTED: bool = false
var LOADING_SCENE_PATH: String = ''
var SKIP_SNAPSHOT: bool = false
var TELEPORT_TO_SAVE: bool = false
var _current_scene_path: String = ''
var _save_system: SaveSystem = null


func _ready() -> void:
	_save_system = get_node("/root/SaveSystem") as SaveSystem
	load_scene(start_scene.resource_path)


func _process(_delta: float) -> void:
	if loading_screen.is_playing(): return
	
	if LOADING_SCENE_PATH.is_empty(): return
	if not LOAD_REQUESTED:
		ResourceLoader.load_threaded_request(LOADING_SCENE_PATH, "", true)
		LOAD_REQUESTED = true
	
	var result = ResourceLoader.load_threaded_get_status(LOADING_SCENE_PATH)
	match result:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var old_scene := CURRENT_SCENE as Node3D
			
			if CURRENT_SCENE: 
				CURRENT_SCENE.queue_free()
			
			if _save_system and not _current_scene_path.is_empty() and old_scene and not SKIP_SNAPSHOT:
				_save_system.snapshot_level(_current_scene_path, old_scene)
			
			var sceneres = ResourceLoader.load_threaded_get(LOADING_SCENE_PATH)
			CURRENT_SCENE = sceneres.instantiate()
			get_tree().current_scene.add_child(CURRENT_SCENE)
			
			if _save_system:
				_save_system.tag_entities(CURRENT_SCENE)
				_save_system.apply_level_state(LOADING_SCENE_PATH, CURRENT_SCENE)
			
			for c in CURRENT_SCENE.get_children():
				if c is Scene:
					player.global_transform = c.player_spawn.global_transform
			if _save_system and TELEPORT_TO_SAVE \
					and _save_system.player_level_path == LOADING_SCENE_PATH \
					and _save_system.player_transform != Transform3D.IDENTITY:
				player.global_transform = _save_system.player_transform
			_current_scene_path = LOADING_SCENE_PATH
			LOADING_SCENE_PATH = ""
			LOAD_REQUESTED = false
			SKIP_SNAPSHOT = false
			TELEPORT_TO_SAVE = false
			loading_screen.hide()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED, ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("failed to load scene")


func load_scene(scene_path: String) -> void:
	if not LOADING_SCENE_PATH.is_empty(): return
	LOADING_SCENE_PATH = scene_path
	loading_screen.show()


func save_scene(_path: String) -> void:
	pass
