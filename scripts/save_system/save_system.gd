extends Node
class_name SaveSystem

const SAVE_DIR: String = "user://saves"
const SAVE_PATH: String = "user://saves/savegame.json"
const VERSION: int = 2

var level_states: Dictionary[String, LevelState] = {}
var inventory_items: Array[Dictionary] = []
var player_transform: Transform3D = Transform3D.IDENTITY
var player_level_path: String = ""


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func snapshot_level(scene_path: String, scene_root: Node3D) -> LevelState:
	var state := LevelState.new()
	state.scene_path = scene_path

	for node in _iter_entities(scene_root):
		if not node.has_meta("save_id"): continue
		state.present_items.append(node.get_meta("save_id"))

	for door in scene_root.find_children("", "Door", true, false):
		var rec := {}
		rec["opened"] = door.OPENED
		rec["locked"] = door.locked
		state.doors[node_path_of(scene_root, door)] = rec

	for gen in scene_root.find_children("", "Generator", true, false):
		var rec := {}
		rec["working"] = gen.WORKING
		state.generators[node_path_of(scene_root, gen)] = rec

	for sw in scene_root.find_children("", "ElectricSwitch", true, false):
		var rec := {}
		rec["enabled"] = sw.ENABLED
		rec["drag_value"] = sw.drag_value
		state.switches[node_path_of(scene_root, sw)] = rec
	for hd in scene_root.find_children("", "GeneratorHandle", true, false):
		var rec := {}
		rec["enabled"] = hd.ENABLED
		rec["drag_value"] = hd.drag_value
		state.switches[node_path_of(scene_root, hd)] = rec

	for body in scene_root.find_children("", "RigidBody3D", true, false):
		var id := _entity_save_id(body)
		if id == "": continue
		state.rigid_bodies[id] = {
			"position": body.global_position,
			"velocity": body.linear_velocity
		}

	for node in _iter_entities(scene_root):
		var id := node.get_meta("save_id", "") as String
		if not id.begins_with("spawned_"): continue
		state.spawned_items[id] = {
			"position": node.global_position,
			"rotation": node.global_rotation
		}

	for slot in scene_root.find_children("", "InventorySlot", true, false):
		if _is_inventory_grid_slot(slot): continue
		var rec := {}
		rec["prefab_id"] = ""
		rec["icon_path"] = ""
		rec["description"] = ""
		if not slot.is_empty():
			var p := slot.PICKABLE as Pickable
			if p:
				rec["prefab_id"] = p.prefab_id
				rec["icon_path"] = _resource_to_path(p.icon)
				rec["description"] = p.description
		state.slot_items[node_path_of(scene_root, slot)] = rec

	level_states[scene_path] = state
	return state


func tag_entities(scene_root: Node3D) -> void:
	for node in _iter_entities(scene_root):
		if not node.has_meta("save_id"):
			node.set_meta("save_id", "static_" + node.name.to_lower())



func apply_level_state(scene_path: String, scene_root: Node3D) -> void:
	var state := level_states.get(scene_path) as LevelState
	if state == null: return

	var entities := scene_root.get_node_or_null("entities") as Node

	for node in _iter_entities(scene_root):
		var id := node.get_meta("save_id", "") as String
		if id == "": continue
		if not state.present_items.has(id):
			node.queue_free()

	if entities:
		for id in state.spawned_items.keys():
			if not state.present_items.has(id): continue
			if _find_entity_by_id(entities, id): continue
			var prefab_id := _prefab_from_spawned_id(id)
			if prefab_id == "": continue
			var inst := _build_world_instance({"prefab_id": prefab_id})
			if inst == null: continue
			inst.set_meta("save_id", id)
			entities.add_child(inst)
			var pos_rot := state.spawned_items[id]
			inst.global_position = pos_rot["position"]
			inst.global_rotation = pos_rot["rotation"]

	for path_key in state.doors.keys():
		var door := scene_root.get_node_or_null(path_key) as Door
		if not door: continue
		door.set_visual_state(state.doors[path_key]["opened"])
		door.sync_interactions()

	for path_key in state.switches.keys():
		var sw := scene_root.get_node_or_null(path_key)
		if sw == null: continue
		if sw is ElectricSwitch:
			sw.ENABLED = state.switches[path_key]["enabled"]
			sw.drag_value = state.switches[path_key]["drag_value"]
		elif sw is GeneratorHandle:
			sw.ENABLED = state.switches[path_key]["enabled"]
			sw.drag_value = state.switches[path_key]["drag_value"]

	for path_key in state.generators.keys():
		var gen := scene_root.get_node_or_null(path_key) as Generator
		if not gen: continue
		if state.generators[path_key]["working"]:
			gen.startup()
		else:
			gen.shutdown()

	for path_key in state.doors.keys():
		var door := scene_root.get_node_or_null(path_key) as Door
		if not door: continue
		door.locked = state.doors[path_key]["locked"]

	for node in _iter_entities(scene_root):
		var id := node.get_meta("save_id", "") as String
		if id == "" or not state.rigid_bodies.has(id): continue
		var body := _find_rigid_body(node)
		if body == null: continue
		body.global_position = state.rigid_bodies[id]["position"]
		body.linear_velocity = state.rigid_bodies[id]["velocity"]

	for slot in scene_root.find_children("", "InventorySlot", true, false):
		if _is_inventory_grid_slot(slot): continue
		var path_key := node_path_of(scene_root, slot)
		var rec: Dictionary = state.slot_items.get(path_key, {})
		if rec.is_empty() or (rec.get("prefab_id", "") as String) == "":
			slot.set_item(null)
		else:
			slot.set_item(_make_inventory_pickable(rec))



func snapshot_inventory(inv: Inventory) -> void:
	inventory_items.clear()
	if inv == null: return
	for slot in inv.get_slots():
		var pickable := slot.PICKABLE as Pickable
		if not pickable: continue
		var rec := {}
		rec["prefab_id"] = pickable.prefab_id
		rec["icon_path"] = _resource_to_path(pickable.icon)
		rec["description"] = pickable.description
		inventory_items.append(rec)


func apply_inventory(inv: Inventory, items: Array[Dictionary]) -> void:
	if inv == null: return
	for slot in inv.get_slots():
		slot.set_item(null)

	var idx := 0
	for item in items:
		if idx >= inv.SLOT_COUNT: break
		var pickable := _make_inventory_pickable(item) as Pickable
		if not pickable: continue
		inv.add_pickable(pickable)
		idx += 1


func build_pickable(rec: Dictionary) -> Node3D:
	return _build_world_instance(rec)


func save_game() -> bool:
	var data := {}
	data["version"] = VERSION
	data["levels"] = []
	for path_key in level_states.keys():
		var st := level_states[path_key] as LevelState
		var rec := {}
		rec["scene_path"] = st.scene_path
		rec["present_items"] = st.present_items.duplicate()
		rec["doors"] = st.doors.duplicate(true)
		rec["generators"] = st.generators.duplicate(true)
		rec["switches"] = st.switches.duplicate(true)
		rec["rigid_bodies"] = _serialize_rigid(st.rigid_bodies)
		rec["spawned_items"] = _serialize_spawned(st.spawned_items)
		rec["slot_items"] = st.slot_items.duplicate(true)
		data["levels"].append(rec)

	var inv := []
	for item in inventory_items:
		inv.append(item.duplicate())
	data["inventory"] = inv

	if player_transform != Transform3D.IDENTITY:
		data["player_position"] = [player_transform.origin.x, player_transform.origin.y, player_transform.origin.z]
		var b := player_transform.basis
		data["player_rotation"] = [b.x.x, b.x.y, b.x.z, b.y.x, b.y.y, b.y.z, b.z.x, b.z.y, b.z.z]
	data["player_level"] = player_level_path

	var tmp_path := SAVE_PATH + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if not file: return false
	file.store_string(JSON.stringify(data))
	file.close()

	var err := DirAccess.rename_absolute(tmp_path, SAVE_PATH)
	if err != OK:
		if FileAccess.file_exists(tmp_path):
			DirAccess.remove_absolute(tmp_path)
		return false
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH): return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY: return false
	data_to_state(parsed as Dictionary)
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func reset_all() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	level_states.clear()
	inventory_items.clear()
	player_transform = Transform3D.IDENTITY
	player_level_path = ""



func data_to_state(data: Dictionary) -> void:
	level_states.clear()
	for rec in data.get("levels", []):
		var st := LevelState.new()
		st.scene_path = rec["scene_path"] as String
		st.present_items.assign(rec.get("present_items", []))
		st.doors = (rec.get("doors", {}) as Dictionary).duplicate(true)
		st.generators = (rec.get("generators", {}) as Dictionary).duplicate(true)
		st.switches = (rec.get("switches", {}) as Dictionary).duplicate(true)
		st.rigid_bodies = _deserialize_rigid(rec.get("rigid_bodies", {}))
		st.spawned_items = _deserialize_spawned(rec.get("spawned_items", {}))
		st.slot_items = (rec.get("slot_items", {}) as Dictionary).duplicate(true)
		level_states[st.scene_path] = st

	inventory_items.clear()
	for item in data.get("inventory", []):
		var rec := (item as Dictionary).duplicate()
		if not rec.has("prefab_id"): continue
		rec["icon_path"] = rec.get("icon_path", "")
		rec["description"] = rec.get("description", "")
		inventory_items.append(rec)

	player_transform = Transform3D.IDENTITY
	player_level_path = data.get("player_level", "") as String
	var pos := data.get("player_position") as Array
	if not pos.is_empty():
		player_transform.origin = Vector3(pos[0], pos[1], pos[2])


func _serialize_rigid(rigid: Dictionary[String, Dictionary]) -> Dictionary:
	var out := {}
	for path_key in rigid.keys():
		out[path_key] = {
			"position": [rigid[path_key]["position"].x, rigid[path_key]["position"].y, rigid[path_key]["position"].z],
			"velocity": [rigid[path_key]["velocity"].x, rigid[path_key]["velocity"].y, rigid[path_key]["velocity"].z]
		}
	return out


func _deserialize_rigid(data: Dictionary) -> Dictionary[String, Dictionary]:
	var out := {} as Dictionary[String, Dictionary]
	for path_key in data.keys():
		var rec = data[path_key]
		if typeof(rec) != TYPE_DICTIONARY: continue
		out[path_key] = {
			"position": Vector3((rec["position"] as Array)[0], (rec["position"] as Array)[1], (rec["position"] as Array)[2]),
			"velocity": Vector3((rec["velocity"] as Array)[0], (rec["velocity"] as Array)[1], (rec["velocity"] as Array)[2])
		}
	return out


func _serialize_spawned(spawned: Dictionary[String, Dictionary]) -> Dictionary:
	var out := {}
	for id in spawned.keys():
		out[id] = {
			"position": [spawned[id]["position"].x, spawned[id]["position"].y, spawned[id]["position"].z],
			"rotation": [spawned[id]["rotation"].x, spawned[id]["rotation"].y, spawned[id]["rotation"].z]
		}
	return out


func _deserialize_spawned(data: Dictionary) -> Dictionary[String, Dictionary]:
	var out := {} as Dictionary[String, Dictionary]
	for id in data.keys():
		var rec = data[id]
		if typeof(rec) != TYPE_DICTIONARY: continue
		out[id] = {
			"position": Vector3((rec["position"] as Array)[0], (rec["position"] as Array)[1], (rec["position"] as Array)[2]),
			"rotation": Vector3((rec["rotation"] as Array)[0], (rec["rotation"] as Array)[1], (rec["rotation"] as Array)[2])
		}
	return out


func _make_inventory_pickable(rec: Dictionary) -> Pickable:
	var prefab_id := rec.get("prefab_id", "") as String
	if prefab_id == "": return null

	var p := Pickable.new()
	p.name = prefab_id.capitalize()
	p.prefab_id = prefab_id
	p.description = rec.get("description", "") as String

	var icon_path := rec.get("icon_path", "") as String
	if icon_path != "" and ResourceLoader.exists(icon_path):
		p.icon = load(icon_path) as Texture2D
	return p


func _build_world_instance(rec: Dictionary) -> Node3D:
	var prefab_id := rec.get("prefab_id", "") as String
	if prefab_id == "": return null

	var path := "res://entities/%s/%s.tscn" % [prefab_id, prefab_id]
	if not ResourceLoader.exists(path): return null
	var ps := load(path) as PackedScene
	if not ps: return null

	return ps.instantiate()


func _resource_to_path(res: Resource) -> String:
	if not res: return ""
	var path := res.get_path()
	if path.begins_with("res://") or path.begins_with("uid://"):
		return path
	return ""


static func node_path_of(root: Node, target: Node) -> String:
	var parts := []
	var n := target
	while n != null and n != root:
		parts.push_front(n.name)
		n = n.get_parent()
	if n != root:
		return target.name
	return "/".join(parts)


func _iter_entities(scene_root: Node3D) -> Array[Node]:
	var out := [] as Array[Node]
	var entities := scene_root.get_node_or_null("entities") as Node
	if not entities: return out
	for child in entities.get_children():
		out.append(child)
	return out


func _find_rigid_body(entity_root: Node) -> RigidBody3D:
	if entity_root is RigidBody3D: return entity_root as RigidBody3D
	for c in entity_root.get_children():
		if c is RigidBody3D: return c as RigidBody3D
	return null


func _entity_save_id(node: Node) -> String:
	var n := node
	while n != null and not n.has_meta("save_id"):
		n = n.get_parent()
	if n == null or not n.has_meta("save_id"): return ""
	return n.get_meta("save_id") as String


func _is_inventory_grid_slot(slot: Node) -> bool:
	var n := slot.get_parent()
	while n != null:
		if n is Inventory:
			return true
		n = n.get_parent()
	return false


func _find_entity_by_id(entities: Node, id: String) -> Node:
	for child in entities.get_children():
		if child.get_meta("save_id", "") == id:
			return child
	return null


func _prefab_from_spawned_id(id: String) -> String:
	if not id.begins_with("spawned_"): return ""
	var rest := id.substr("spawned_".length())
	var underscore := rest.rfind("_")
	if underscore <= 0: return rest
	return rest.substr(0, underscore)
