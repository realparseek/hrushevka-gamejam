extends Node

@onready var interactions: Dictionary = {}

func _ready() -> void:
	for c in get_children():
		if c is not Interaction:
			continue
		
		interactions[c.name.to_lower()] = c
		c.Interacted.connect(_on_interacted)

func _on_interacted(interaction: String) -> void:
	if interaction.to_lower() not in interactions:
		return
	
	interactions[interaction.to_lower()].interacte()
