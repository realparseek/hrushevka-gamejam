extends Node
class_name Generator

@export var lights: Array[OmniLight3D]
@export var doors: Array[Door]
@export var switches_bodies: Array[StaticBody3D]
@export var audio_player: SpatialAudioPlayer3D
@export var fuse_sound: SpatialAudioPlayer3D
@export var explosion_sound: SpatialAudioPlayer3D
@export var electricity_sound: SpatialAudioPlayer3D
@export var working_sound: AudioStream
@export var outage_sound: AudioStream

var WORKING: bool = true
var SWITCHES: Array[ElectricSwitch]

func _ready() -> void:
	if working_sound and audio_player:
		audio_player.stream = working_sound
		audio_player.set("parameters/looping", true)
		audio_player.play()

	for sb in switches_bodies:
		for c in sb.get_children():
			if c is ElectricSwitch:
				SWITCHES.append(c)
				continue
	shutdown()

func _process(_delta: float) -> void:
	var slot := get_node_or_null("../slot") as Node
	if slot == null: return
	var uslot := slot.get_node_or_null("uslot") as Control
	if uslot == null: return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null: return
	var objpos: Vector2 = camera.unproject_position(slot.global_position)

	if not camera.is_position_behind(slot.global_position):
		uslot.visible = true
		uslot.modulate.a = 0.0
		uslot.position = Vector2(
			objpos.x - uslot.size.x/2.0, 
			objpos.y - uslot.size.y/2.0)
	else:
		uslot.visible = false

	for s in SWITCHES:
		if not s.ENABLED: return
	shutdown()

func shutdown() -> void:
	if not WORKING: return
	for l in lights:
		if l: l.light_energy = 0.0
	for d in doors:
		if d: d.locked = true

	if outage_sound and audio_player:
		audio_player.stream = outage_sound
		audio_player.set("parameters/looping", false)
		audio_player.play()
	WORKING = false
	if electricity_sound: electricity_sound.play()

func startup() -> void:
	if WORKING: return
	for l in lights:
		if l: l.light_energy = 1.0
	for d in doors:
		if d: d.locked = false

	if working_sound and audio_player:
		audio_player.stream = working_sound
		audio_player.set("parameters/looping", true)
		audio_player.play()
	WORKING = true
	if electricity_sound: electricity_sound.play()
