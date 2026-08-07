extends Draggable
class_name ElectricSwitch

@export var drag_sensetivity: float = 1.0
@export var snap_distance: float = 0.05
@export var snap_acceleration: float = 0.07
@export var switch_sound: SpatialAudioPlayer3D
@export var switch_mesh: MeshInstance3D
@export var switch_start_rot: float = 0.0
@export var switch_end_rot: float = 170.0

var DRAG_START_VALUE: float = 0.0
var ENABLED: bool = false

func _ready() -> void:
	_m_adjust_rot()

func start_dragging() -> void:
	super()
	DRAG_START_VALUE = drag_value

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_m_adjust_rot()
		drag(-event.relative.y * drag_sensetivity)
		if (1.0-drag_value) <= snap_distance and DRAG_START_VALUE != 1.0 and IS_DRAGGING:
			if switch_sound:
				switch_sound.play()
			drag_value = 1.0
			ENABLED = true
			stop_dragging()

		if drag_value <= snap_distance and DRAG_START_VALUE != 0.0 and IS_DRAGGING:
			if switch_sound:
				switch_sound.play()
			drag_value = 0.0
			ENABLED = false
			stop_dragging()

func _m_adjust_rot() -> void:
	switch_mesh.rotation.x = deg_to_rad(drag_value*absf(switch_end_rot-switch_start_rot))
