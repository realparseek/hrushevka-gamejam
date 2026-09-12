extends Node
class_name PickableSpawner

@export var scene_loader: SceneLoader

func spawn(prefab_id: String) -> Node3D:
	print("res://entities/" + prefab_id + "/" + prefab_id + ".tscn")
	var res: Resource = load("res://entities/" + prefab_id + "/" + prefab_id + ".tscn")
	var node: Node3D = res.instantiate()
	scene_loader.CURRENT_SCENE.get_node("entities").add_child(node)
	return node
