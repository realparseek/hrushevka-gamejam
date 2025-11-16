extends Node
class_name Interactable

@onready var interactions: Dictionary = {}

func _ready() -> void:
	for c in get_children():
		if c is not Interaction:
			continue
		interactions[c.name.to_lower()] = c

func interacte(interaction: String) -> void:
	if interaction.to_lower() not in interactions:
		return
	interactions[interaction.to_lower()].interacte()

func hover() -> void:
	pass

func unhover() -> void:
	pass
