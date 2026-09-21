extends ColorRect
class_name DropArea

@export var player: CharacterBody3D
@export var entity_spawner: PickableSpawner
@export var interaction_cast: InteractionCast
@export var player_body: CharacterBody3D

func _can_drop_data(_at_pos: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	var global_target_pos = interaction_cast.raycast.target_position
	global_target_pos = global_target_pos.rotated(Vector3.RIGHT, interaction_cast.raycast.global_rotation.x)
	global_target_pos = global_target_pos.rotated(Vector3.UP, interaction_cast.raycast.global_rotation.y)
	var check_query = PhysicsRayQueryParameters3D.create(player.global_position, player.global_position + global_target_pos)
	check_query.hit_back_faces = false
	var world3d = (get_tree().root.get_child(0) as Node3D).get_world_3d()
	var dspace = world3d.direct_space_state
	if dspace.intersect_ray(check_query).size() != 0: return

	var ent: RigidBody3D = entity_spawner.spawn(data.PICKABLE.prefab_id)
	var global_target: Vector3 = interaction_cast.raycast.target_position
	global_target = global_target.rotated(Vector3.UP, player_body.global_rotation.y)
	ent.global_position = player_body.global_position

	ent.global_position += global_target_pos
	ent.linear_velocity += global_target_pos * 1.5
	
	data.PICKABLE.on_drop(player_body)
	data.set_item(null)
