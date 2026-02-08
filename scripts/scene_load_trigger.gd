extends Area3D
class_name SceneLoadTrigger

@export var load_scenes: Array[String]
@export var unload_scenes: Array[String]

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node3D) -> void:
	for s in load_scenes:
		$'../..'.load_scene(s)
	for s in unload_scenes:
		$'../..'.unload_scene(s)
