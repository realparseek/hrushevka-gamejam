extends Interaction
class_name Enter

@export var scene_name: String

var scene_loader: SceneLoader = null

func interacte(player: CharacterBody3D) -> void:
	for loader in player.get_children():
		if loader is not SceneLoader: continue
		loader.load_scene("res://scenes/" + scene_name + "/" + scene_name + ".tscn")
		return
