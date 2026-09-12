extends ColorRect
class_name DropArea

@export var entity_spawner: PickableSpawner
@export var interaction_cast: InteractionCast
@export var player_body: CharacterBody3D

func _can_drop_data(_at_pos: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	if interaction_cast.raycast.get_collider(): return
	var ent: RigidBody3D = entity_spawner.spawn(data.PICKABLE.prefab_id)
	var global_target: Vector3 = interaction_cast.raycast.target_position
	global_target = global_target.rotated(Vector3.UP, player_body.global_rotation.y)
	ent.global_position = player_body.global_position
	ent.global_position += global_target*0.5
	ent.linear_velocity = global_target * 3.0
	data.PICKABLE.on_drop(player_body)
	data.set_item(null)
