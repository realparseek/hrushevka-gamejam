extends Node
class_name SceneLoader

@export var root: Node3D
@export var player: CharacterBody3D
@export var start_scene: PackedScene

var CURRENT_SCENE: Node3D = null
var CURRENT_SCENE_PATH: String = ''
var LOADARRAY: Array

func _ready() -> void:
	set_process(false)
	load_scene(start_scene.resource_path)

func _process(_delta: float) -> void:
	var result = ResourceLoader.load_threaded_get_status(CURRENT_SCENE_PATH, LOADARRAY)
	match result:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var sceneres = ResourceLoader.load_threaded_get(CURRENT_SCENE_PATH)
			CURRENT_SCENE = sceneres.instantiate()
			root.add_child(CURRENT_SCENE)
			
			for c in CURRENT_SCENE.get_children():
				if c is Scene:
					player.global_transform = c.player_spawn.global_transform
			
			set_process(false)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED, ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("failed to load scene")
			set_process(false)

func load_scene(scene_path: String) -> void:
	if CURRENT_SCENE:
		CURRENT_SCENE.queue_free()
		CURRENT_SCENE = null
	CURRENT_SCENE_PATH = scene_path
	ResourceLoader.load_threaded_request(scene_path, "", true)
	set_process(true)
