extends Node
class_name SceneLoader

@export var root: Node3D
@export var player: CharacterBody3D
@export var CURRENT_SCENE: Node3D = null

var CURRENT_SCENE_PATH: String = ''

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	var result = ResourceLoader.load_threaded_get_status(CURRENT_SCENE_PATH)
	if result == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		var sceneres = ResourceLoader.load_threaded_get(CURRENT_SCENE_PATH)
		CURRENT_SCENE = sceneres.instantiate()
		root.add_child(CURRENT_SCENE)
		print("scene loaded")
		set_process(false)

func load_scene(scene_path: String) -> void:
	CURRENT_SCENE.queue_free()
	CURRENT_SCENE = null
	CURRENT_SCENE_PATH = scene_path
	ResourceLoader.load_threaded_request(scene_path, "", true)
	set_process(true)
