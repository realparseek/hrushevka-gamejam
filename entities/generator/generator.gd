extends Node
class_name Generator

@export var lights: Array[OmniLight3D]
@export var switches_bodies: Array[StaticBody3D]
@export var audio_player: SpatialAudioPlayer3D
@export var electric_shock_sound: SpatialAudioPlayer3D
@export var sparkles: GPUParticles3D

var WORKING: bool = true

var SWITCHES: Array[ElectricSwitch]

var WORKING_SOUND: AudioStream = preload("res://assets/audio/generator/generator.mp3")
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
	for s in SWITCHES:
		if not s.ENABLED: return
  
	shutdown()

func shutdown() -> void:
	if not WORKING: return
	for l in lights:
		l.light_energy = 0.0
  
	if not audio_player: return
	audio_player.stream = OUTAGE_SOUND
	audio_player.set("parameters/looping", false)
	audio_player.play()
	WORKING = false
	sparkles.visible = true
	electric_shock_sound.play()
	$"../probka".play()
	$"../explosion".play()
