extends Draggable
class_name GeneratorHandle

@export var drag_sensetivity: float = 1.0
@export var snap_distance: float = 0.05
@export var snap_acceleration: float = 0.05
@export var handle_sound: SpatialAudioPlayer3D
@export var handle_mesh: MeshInstance3D
@export var handle_start_pos: float = -0.163
@export var handle_end_pos: float = -0.284

var DRAG_START_VALUE: float = 0.0
var ENABLED: bool = false
var POWERON_VALUE: float = 0.0

func _ready() -> void:
	_m_adjust_rot(0.0)

func _process(delta: float) -> void:
	_m_adjust_rot(delta)
	handle_mesh.position.z = lerp(handle_start_pos, handle_end_pos, drag_value)
	if drag_value < 1.0 and ENABLED: ENABLED = false
	if POWERON_VALUE == 1.0:
		POWERON_VALUE = 0.0
		$"../../generator/generator".startup()

func start_dragging() -> void:
	super()
	DRAG_START_VALUE = drag_value

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		drag(event.relative.y * drag_sensetivity * 0.01)
		if (1.0-drag_value) <= snap_distance and DRAG_START_VALUE != 1.0 and IS_DRAGGING:
			if handle_sound:
				handle_sound.play()
				if not $"../../generator/generator".WORKING:
					POWERON_VALUE = min(1.0, POWERON_VALUE+0.35)
			drag_value = 1.0
			ENABLED = true
			stop_dragging()

func _m_adjust_rot(delta: float) -> void:
	if not IS_DRAGGING:
		drag_value = lerp(drag_value, 0.0, delta*2.5)
