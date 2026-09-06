extends Node
class_name SceneLoader

@export var player: CharacterBody3D
@export var start_scene: PackedScene
@export var loading_screen: LoadingScreen

var CURRENT_SCENE: Node3D = null
var LOAD_REQUESTED: bool = false
var LOADING_SCENE_PATH: String = ''

func _ready() -> void:
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
			if CURRENT_SCENE: 
				#for c in CURRENT_SCENE.get_children():
					#if c is Scene:
						#c.save_data("res://resources/save.tres")
						#break
				CURRENT_SCENE.queue_free()
			
			var sceneres = ResourceLoader.load_threaded_get(LOADING_SCENE_PATH)
			CURRENT_SCENE = sceneres.instantiate()
			get_tree().current_scene.add_child(CURRENT_SCENE)
			
			for c in CURRENT_SCENE.get_children():
				if c is Scene:
					player.global_transform = c.player_spawn.global_transform
					#c.load_data("res://resources/save.tres")
			LOADING_SCENE_PATH = ""
			LOAD_REQUESTED = false
			loading_screen.hide()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED, ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("failed to load scene")

func load_scene(scene_path: String) -> void:
	if not LOADING_SCENE_PATH.is_empty(): return
	LOADING_SCENE_PATH = scene_path
	loading_screen.show()

func save_scene(path: String) -> void:
	pass
