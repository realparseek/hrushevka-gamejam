extends Node3D
@onready var scenes_loading: Array[String]
@onready var scenes_loaded: Array[String]

func _ready() -> void:
	load_scene('enterence')
	load_scene('transition')

func _process(_delta: float) -> void:
	for s in scenes_loading:
		if ResourceLoader.load_threaded_get_status('res://scenes/' + s + '.tscn') == ResourceLoader.THREAD_LOAD_FAILED:
			print("FAILED TO LOAD SCENE - ", s)
			get_tree().exit(1)
		if ResourceLoader.load_threaded_get_status('res://scenes/' + s + '.tscn') != ResourceLoader.THREAD_LOAD_LOADED:
			continue
		var scene: Resource = ResourceLoader.load_threaded_get('res://scenes/' + s + '.tscn')
		var scene_inst = scene.instantiate()
		add_child(scene_inst)
		print('Scene loaded: ' + s)
		scenes_loading.erase(s)
		scenes_loaded.append(s)

func load_scene(scene_name: String) -> void:
	if scene_name in scenes_loading:
		return
	if scene_name in scenes_loaded:
		return
	ResourceLoader.load_threaded_request('res://scenes/' + scene_name + '.tscn', '', false)
	scenes_loading.append(scene_name)
	print('Scene loading - ', scene_name)

func unload_scene(scene_name: String) -> void:
	if scene_name in scenes_loading:
		return
	if scene_name not in scenes_loaded:
		return
	get_node(scene_name).queue_free()
	scenes_loaded.erase(scene_name)
	print('Scene unloaded - ', scene_name)
