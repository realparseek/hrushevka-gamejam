extends Interactable
class_name Pickable

@export var icon: Texture2D
@export_multiline var description: String
@export var prefab_id: String
@export var item: ItemData

func on_drop(_player: CharacterBody3D) -> void: pass
