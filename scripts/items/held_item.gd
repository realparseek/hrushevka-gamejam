extends Node3D
class_name HeldItem

@export_subgroup("Ссылки")
@export var camera: Camera3D
@export var player: CharacterBody3D
@export var inventory: Inventory
@export var pause_menu: PauseMenu
@export var spawner: PickableSpawner

@export_subgroup("Положение в руках")
@export var hold_position: Vector3 = Vector3(0.30, -0.22, -0.50)
@export var hold_rotation_deg: Vector3 = Vector3(0.0, -30.0, 8.0)
@export var hold_scale: float = 1.0

@export_subgroup("Инерция предмета")
@export var sway_per_speed: float = 0.035
@export var sway_stiffness: float = 45.0
@export var sway_damping: float = 11.0
@export var sway_max: float = 0.12
@export var rotation_lag: float = 0.5
@export var rotation_lag_recovery: float = 10.0
@export var rotation_lag_max_deg: float = 12.0

@export_subgroup("Анимация")
@export var equip_speed: float = 7.0
@export var holster_offset: Vector3 = Vector3(0.05, -0.40, -0.10)
@export var holster_rotation_deg: Vector3 = Vector3(40.0, -15.0, 30.0)

@export_subgroup("Бросок")
@export var throw_force: float = 7.0
@export var throw_upward: float = 1.5
@export var throw_spawn_distance: float = 0.6

var _current: ItemData = null
var _equipped: bool = false
var _equip_t: float = 0.0
var _sway: Vector3 = Vector3.ZERO
var _sway_velocity: Vector3 = Vector3.ZERO
var _rot_lag: Vector3 = Vector3.ZERO
var _visual: Node3D = null
var _hold_pos: Vector3
var _hold_rot: Vector3
var _hold_scale: float = 1.0
var _prev_cam_basis: Basis = Basis.IDENTITY
var _has_prev_basis: bool = false

func _ready() -> void:
	_hold_pos = hold_position
	_hold_rot = _deg3(hold_rotation_deg)
	_hold_scale = hold_scale
	_clear_visual()
	visible = false
	if camera:
		_prev_cam_basis = camera.global_transform.basis.orthonormalized()
		_has_prev_basis = true
	_connect_slots.call_deferred()

func equip(data: ItemData) -> void:
	if data == null:
		return
	_current = data
	_hold_pos = data.hold_position if data.hold_position != Vector3.ZERO else hold_position
	var rot_src: Vector3 = data.hold_rotation_deg if data.hold_rotation_deg != Vector3.ZERO else hold_rotation_deg
	_hold_rot = _deg3(rot_src)
	_hold_scale = data.hold_scale if data.hold_scale > 0.0 else hold_scale
	_build_visual(data)
	_equipped = true
	visible = true

func holster() -> void:
	_equipped = false

func toggle(data: ItemData) -> void:
	if _equipped and _current == data:
		holster()
	else:
		equip(data)

func cycle(direction: int) -> void:
	if inventory == null:
		return
	var list: Array[ItemData] = []
	for p in inventory.get_pickables():
		var d: ItemData = item_data_of(p)
		if d:
			list.append(d)
	if list.is_empty():
		return
	var idx: int = list.find(_current)
	if idx < 0:
		idx = 0
	else:
		idx = wrapi(idx + direction, 0, list.size())
	equip(list[idx])

func is_holding() -> bool:
	return _equipped

func current_item() -> ItemData:
	return _current

static func item_data_of(pickable: Pickable) -> ItemData:
	if pickable == null:
		return null
	if pickable.item != null:
		return pickable.item
	var data: ItemData = ItemData.new()
	data.id = pickable.prefab_id
	data.display_name = pickable.prefab_id
	data.description = pickable.description
	data.icon = pickable.icon
	data.prefab_id = pickable.prefab_id
	if pickable.prefab_id != "":
		var path: String = "res://entities/%s/%s.tscn" % [pickable.prefab_id, pickable.prefab_id]
		if ResourceLoader.exists(path):
			data.world_scene_path = path
	return data

func _process(delta: float) -> void:
	if pause_menu and pause_menu.PAUSED:
		return
	if delta <= 0.0:
		return

	if _equipped and not _item_still_in_inventory():
		holster()
		_current = null

	var target_t: float = 1.0 if _equipped else 0.0
	_equip_t = move_toward(_equip_t, target_t, equip_speed * delta)
	visible = _equip_t > 0.001
	if not visible:
		return

	_update_sway(delta)
	_update_rotation_lag(delta)

	var t: float = _equip_t * _equip_t * (3.0 - 2.0 * _equip_t)
	var pos: Vector3 = (_hold_pos + holster_offset).lerp(_hold_pos, t)
	var holster_rot: Vector3 = _deg3(holster_rotation_deg)
	var rot: Vector3 = (holster_rot + _hold_rot).lerp(_hold_rot, t)

	var desired_local: Vector3 = pos + _sway

	if camera != null:
		var space_state = get_world_3d().direct_space_state
		if space_state != null:
			var cam_pos: Vector3 = camera.global_position
			var target_world: Vector3 = cam_pos + camera.global_transform.basis * desired_local
			var query = PhysicsRayQueryParameters3D.create(cam_pos, target_world)
			query.collision_mask = 0xFFFFFFFF
			if player != null:
				query.exclude = [player.get_rid()]
			var result: Dictionary = space_state.intersect_ray(query)
			if not result.is_empty():
				var hit_pos: Vector3 = result.position
				var full_dist: float = cam_pos.distance_to(target_world)
				var hit_dist: float = cam_pos.distance_to(hit_pos)
				if full_dist > 0.001 and hit_dist < full_dist:
					var scale_factor: float = (hit_dist - 0.05) / full_dist
					scale_factor = clampf(scale_factor, 0.1, 1.0)
					desired_local = desired_local * scale_factor

	position = desired_local
	rotation = rot + _rot_lag
	scale = Vector3.ONE * _hold_scale

func _update_sway(delta: float) -> void:
	var target: Vector3 = Vector3.ZERO
	if player and camera:
		var planar: Vector3 = Vector3(player.velocity.x, 0.0, player.velocity.z)
		var local_vel: Vector3 = camera.global_transform.basis.inverse() * planar
		target = Vector3(-local_vel.x, 0.0, -local_vel.z) * sway_per_speed
	var force: Vector3 = (target - _sway) * sway_stiffness - _sway_velocity * sway_damping
	_sway_velocity += force * delta
	_sway += _sway_velocity * delta
	_sway = _sway.limit_length(sway_max)

func _update_rotation_lag(delta: float) -> void:
	if camera:
		var cam_basis: Basis = camera.global_transform.basis.orthonormalized()
		if _has_prev_basis:
			var rel: Basis = _prev_cam_basis.inverse() * cam_basis
			_rot_lag += -rel.get_euler() * rotation_lag
		_prev_cam_basis = cam_basis
		_has_prev_basis = true
	_rot_lag = _rot_lag.lerp(Vector3.ZERO, clampf(rotation_lag_recovery * delta, 0.0, 1.0))
	_rot_lag = _rot_lag.limit_length(deg_to_rad(rotation_lag_max_deg))

func _connect_slots() -> void:
	if inventory == null:
		return
	for s in inventory.get_slots():
		var icon_node: Node = null
		var holder: Node = s.get_parent()
		if holder:
			icon_node = holder.get_node_or_null("icon")
		if icon_node == null:
			icon_node = s.get_node_or_null("icon")
		if icon_node and icon_node.has_signal("equip_requested"):
			var handler: Callable = _on_slot_equip_requested.bind(s)
			if not icon_node.equip_requested.is_connected(handler):
				icon_node.equip_requested.connect(handler)

func _on_slot_equip_requested(slot: InventorySlot) -> void:
	if slot == null or slot.is_empty():
		return
	var data: ItemData = item_data_of(slot.PICKABLE)
	if data == null:
		return
	toggle(data)

func throw_held() -> void:
	if not _equipped or _current == null:
		return
	var thrown: ItemData = _current
	var ent = _spawn_in_world_with_check(thrown)
	if ent == null:
		return
	_remove_from_inventory(thrown)
	holster()
	_current = null

func _spawn_in_world_with_check(data: ItemData) -> Node3D:
	if data == null:
		return null
	var ent: Node3D = null
	if spawner != null and data.prefab_id != "":
		ent = spawner.spawn(data.prefab_id)
	elif data.world_scene_path != "" and ResourceLoader.exists(data.world_scene_path):
		var ps: PackedScene = load(data.world_scene_path)
		if ps:
			ent = ps.instantiate() as Node3D
			var parent: Node = _entities_parent()
			if parent == null and get_tree() != null:
				parent = get_tree().current_scene
			if parent == null:
				parent = self
			parent.add_child(ent)
	if ent == null:
		return null

	var dir: Vector3 = -camera.global_transform.basis.z if camera else Vector3.FORWARD
	var cam_pos: Vector3 = camera.global_position if camera else global_position
	var origin: Vector3 = cam_pos + dir * throw_spawn_distance

	var space_state = get_world_3d().direct_space_state
	var check_query = PhysicsRayQueryParameters3D.create(cam_pos, origin)
	check_query.hit_back_faces = false
	check_query.collision_mask = 0xFFFFFFFF
	if player != null:
		check_query.exclude = [player.get_rid()]
	var check_result: Dictionary = space_state.intersect_ray(check_query)

	if not check_result.is_empty():
		ent.global_position = check_result.position + check_result.normal * 0.15
	else:
		ent.global_position = origin

	if ent is RigidBody3D:
		var rb: RigidBody3D = ent
		rb.linear_velocity = dir * throw_force + Vector3.UP * throw_upward
		rb.angular_velocity = Vector3(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	return ent

func _spawn_in_world(data: ItemData) -> Node3D:
	if data == null:
		return null
	var ent: Node3D = null
	if spawner != null and data.prefab_id != "":
		ent = spawner.spawn(data.prefab_id)
	elif data.world_scene_path != "" and ResourceLoader.exists(data.world_scene_path):
		var ps: PackedScene = load(data.world_scene_path)
		if ps:
			ent = ps.instantiate() as Node3D
			var parent: Node = _entities_parent()
			if parent == null and get_tree() != null:
				parent = get_tree().current_scene
			if parent == null:
				parent = self
			parent.add_child(ent)
	if ent == null:
		return null

	var dir: Vector3 = -camera.global_transform.basis.z if camera else Vector3.FORWARD
	var origin: Vector3 = (camera.global_position if camera else global_position) + dir * throw_spawn_distance
	ent.global_position = origin
	if ent is RigidBody3D:
		var rb: RigidBody3D = ent
		rb.linear_velocity = dir * throw_force + Vector3.UP * throw_upward
		rb.angular_velocity = Vector3(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	return ent

func _entities_parent() -> Node:
	if spawner != null and spawner.scene_loader != null and spawner.scene_loader.CURRENT_SCENE != null:
		return spawner.scene_loader.CURRENT_SCENE.get_node_or_null("entities")
	return null

func _remove_from_inventory(data: ItemData) -> void:
	if inventory == null or data == null:
		return
	var key: String = _key_of(data)
	if key == "":
		return
	for s in inventory.get_slots():
		if s.is_empty():
			continue
		if _key_of(item_data_of(s.PICKABLE)) == key:
			s.set_item(null)
			return

func _item_still_in_inventory() -> bool:
	if inventory == null or _current == null:
		return true
	var key: String = _key_of(_current)
	if key == "":
		return true
	for p in inventory.get_pickables():
		if _key_of(item_data_of(p)) == key:
			return true
	return false

static func _key_of(data: ItemData) -> String:
	if data == null:
		return ""
	return data.id if data.id != "" else data.display_name

func _unhandled_input(event: InputEvent) -> void:
	if pause_menu and pause_menu.PAUSED:
		return
	if event.is_action_pressed("item_hold_toggle"):
		if _equipped:
			holster()
		elif _current:
			equip(_current)
	elif event.is_action_pressed("item_hold_next"):
		cycle(1)
	elif event.is_action_pressed("item_hold_prev"):
		cycle(-1)
	elif event.is_action_pressed("item_throw"):
		throw_held()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		throw_held()

func _build_visual(data: ItemData) -> void:
	_clear_visual()
	var node: Node3D = null
	if data.hand_scene:
		node = data.hand_scene.instantiate() as Node3D
	elif data.hand_mesh:
		var mi: MeshInstance3D = MeshInstance3D.new()
		mi.mesh = data.hand_mesh
		if data.hand_material:
			mi.material_override = data.hand_material
		node = mi
	elif data.world_scene_path != "" and ResourceLoader.exists(data.world_scene_path):
		var ps: PackedScene = load(data.world_scene_path)
		if ps:
			node = _mesh_from_prefab(ps)
	if node == null:
		node = _placeholder()
	add_child(node)
	_visual = node

func _mesh_from_prefab(prefab: PackedScene) -> MeshInstance3D:
	var inst: Node = prefab.instantiate()
	var src: MeshInstance3D = _find_first_mesh(inst)
	var out: MeshInstance3D = null
	if src and src.mesh:
		out = MeshInstance3D.new()
		out.mesh = src.mesh
		if src.material_override:
			out.material_override = src.material_override
		else:
			var count: int = src.get_surface_override_material_count()
			for i in range(count):
				var mat: Material = src.get_surface_override_material(i)
				if mat:
					out.set_surface_override_material(i, mat)
	inst.free()
	return out

func _find_first_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for c in node.get_children():
		var found: MeshInstance3D = _find_first_mesh(c)
		if found:
			return found
	return null

func _placeholder() -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.07
	sphere.height = 0.14
	mi.mesh = sphere
	return mi

func _clear_visual() -> void:
	for c in get_children():
		remove_child(c)
		c.free()
	_visual = null

func _deg3(v: Vector3) -> Vector3:
	return Vector3(deg_to_rad(v.x), deg_to_rad(v.y), deg_to_rad(v.z))
