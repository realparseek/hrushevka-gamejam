extends Interactable

func _ready() -> void:
	super()
	debug_name = 'Документ об эвакуции жителей'

func hover() -> void:
	$"../plane/outline".visible = true

func unhover() -> void:
	$"../plane/outline".visible = false
