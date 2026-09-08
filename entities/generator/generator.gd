extends Node
class_name Generator

@export var lights: Array[OmniLight3D]
@export var switches_bodies: Array[StaticBody3D]
@export var audio_player: SpatialAudioPlayer3D
@export var fuse_sound: SpatialAudioPlayer3D
@export var explosion_sound: SpatialAudioPlayer3D
@export var electricity_sound: SpatialAudioPlayer3D
@export var sparkles: GPUParticles3D

var WORKING: bool = true

var SWITCHES: Array[ElectricSwitch]

var WORKING_SOUND: AudioStream = preload("res://assets/audio/generator/generatoridle.ogg")
var OUTAGE_SOUND: AudioStream = preload("res://assets/audio/generator/powerout.mp3")

func _ready() -> void:
	audio_player.stream = WORKING_SOUND
	audio_player.set("parameters/looping", true)
	audio_player.play()

	for sb in switches_bodies:
		for c in sb.get_children():
			if c is ElectricSwitch:
				SWITCHES.append(c)
				continue

func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var objpos: Vector2 = camera.unproject_position($"../slot".global_position)
	
	if not camera.is_position_behind($"../slot".global_position):
		$"../islot".visible = true
		$"../islot".position = Vector2(objpos.x - $"../slot".size.x/2.0, objpos.y - $"../slot".size.y/2.0)
		#$"../islot".size = dotsize
	else:
		$"../islot".visible = false
	
	for s in SWITCHES:
		if not s.ENABLED: return
	shutdown()

func shutdown() -> void:
	if not WORKING: return
	for l in lights: l.light_energy = 0.0
  
	if not audio_player: return
	audio_player.stream = OUTAGE_SOUND
	audio_player.set("parameters/looping", false)
	audio_player.play()
	WORKING = false
	sparkles.visible = true
	electricity_sound.play()
	explosion_sound.play()
	fuse_sound.play()
