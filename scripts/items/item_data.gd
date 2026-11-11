extends Resource
class_name ItemData

@export_group("Основное")
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("В мире")
@export var prefab_id: String = ""
@export_file("*.tscn") var world_scene_path: String = ""

@export_group("В руках")
@export var hand_scene: PackedScene
@export var hand_mesh: Mesh
@export var hand_material: Material
@export var hold_position: Vector3 = Vector3(0.30, -0.22, -0.50)
@export var hold_rotation_deg: Vector3 = Vector3(0.0, -30.0, 8.0)
@export var hold_scale: float = 1.0
