extends Interaction
class_name Enter

@export var scene: PackedScene

var scene_loader: SceneLoader = null

func _ready() -> void:
	for c in get_tree().current_scene.get_children():
		if c is not SceneLoader: continue
		scene_loader = c
		return
	print('failed to find scene loader')

func interacte() -> void:
	scene_loader.load_scene(scene.resource_path)
