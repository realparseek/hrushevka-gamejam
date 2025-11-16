extends Interactable

func _ready() -> void:
	super()
	debug_name = 'Электрощиток'

func hover() -> void:
	$"../switch/outline".visible = true

func unhover() -> void:
	$"../switch/outline".visible = false
