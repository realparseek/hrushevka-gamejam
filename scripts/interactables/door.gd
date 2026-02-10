extends Interactable

func _ready() -> void:
	super()
	debug_name = 'Дверь'

func hover() -> void:
	$"../door/doorknob1".get_active_material(0).stencil_mode = BaseMaterial3D.STENCIL_MODE_OUTLINE
	$"../door/doorknob1".get_active_material(0).stencil_color = Color(0.75, 0.75, 0.75)
	$"../door/doorknob1".get_active_material(0).stencil_outline_thickness = 0.005

func unhover() -> void:
	$"../door/doorknob1".get_active_material(0).stencil_mode = BaseMaterial3D.STENCIL_MODE_DISABLED
