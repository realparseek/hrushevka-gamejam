extends Node
class_name PickableSpawner

@export var scene_loader: SceneLoader

var _spawn_counter: int = 0


func spawn(prefab_id: String) -> Node3D:
	print("res://entities/" + prefab_id + "/" + prefab_id + ".tscn")
	var res: Resource = load("res://entities/" + prefab_id + "/" + prefab_id + ".tscn")
	var node: Node3D = res.instantiate()
	_spawn_counter += 1
	node.set_meta("save_id", "spawned_%s_%d" % [prefab_id, _spawn_counter])
	scene_loader.CURRENT_SCENE.get_node("entities").add_child(node)
	return node
