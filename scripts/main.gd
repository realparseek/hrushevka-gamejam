extends Node3D

@onready var current_scene: Resource = null
@onready var current_scene_node: Node3D = null
@onready var previous_scene_node: Node3D = null
@onready var loading_scene: String = ''
@onready var is_loading: bool = false

func _ready() -> void:
	load_scene('enterence')

func _process(delta: float) -> void:
	if is_loading:
		if ResourceLoader.load_threaded_get_status('res://scenes/' + loading_scene + '.tscn') == ResourceLoader.THREAD_LOAD_LOADED:
			return
		#if current_scene:
			#current_scene_node.queue_free()
		current_scene = ResourceLoader.load_threaded_get('res://scenes/' + loading_scene + '.tscn')
		var scene_inst = current_scene.instantiate()
		add_child(scene_inst)
		print('Scene loaded: ' + loading_scene)
		current_scene_node = get_node(loading_scene)
		loading_scene = ''
		is_loading = false
	else:
		if current_scene_node.name == 'enterence':
			if $'enterence/transition_trigger'.has_overlapping_bodies():
				load_scene('transition')
			

func load_scene(path: String) -> void:
	ResourceLoader.load_threaded_request('res://scenes/' + path + '.tscn')
	loading_scene = path
	is_loading = true
