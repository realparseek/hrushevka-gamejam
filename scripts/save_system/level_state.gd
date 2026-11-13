extends RefCounted
class_name LevelState

var scene_path: String = ""
var present_items: Array[String] = []
var doors: Dictionary = {}
var generators: Dictionary = {}
var rigid_bodies: Dictionary[String, Dictionary] = {}
var switches: Dictionary = {}
var spawned_items: Dictionary[String, Dictionary] = {}
var slot_items: Dictionary = {}
