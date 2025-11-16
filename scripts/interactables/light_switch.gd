extends Interactable

func hover() -> void:
	$"../switch/outline".visible = true

func unhover() -> void:
	$"../switch/outline".visible = false
