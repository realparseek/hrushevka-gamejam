extends Node
class_name Scene

@export var player_spawn: Node3D

var DATA: SceneData

func save_data(path: String) -> void:
	var fuse: RigidBody3D = get_tree().current_scene.get_node("bunker/entities/fuse")
	if not fuse: 
		print("duh")
		return
	DATA = SceneData.new()
	DATA.fuse_position = fuse.global_position
	DATA.fuse_velocity = fuse.linear_velocity
	if ResourceSaver.save(DATA, path) == OK:
		print("scene data saved")
	else:
		print("failed to save scene data")

func load_data(path: String) -> void:
	var data: SceneData = ResourceLoader.load(path)
	if not data: return
	var fuse: RigidBody3D = get_tree().current_scene.get_node("bunker/entities/fuse")
	if not fuse: return
	
	fuse.global_position = data.fuse_position
	fuse.linear_velocity = data.fuse_velocity
