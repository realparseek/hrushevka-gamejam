extends Node
class_name Interactable

var interactions: Dictionary[String,Interaction] = {}

var MESSAGE: String = ''
var MESSAGETIME: float = 0.0

func _ready() -> void:
	if len(interactions): interactions.clear()
	for c in get_children():
		if c is Interaction:
			interactions[c.name.to_lower()] = c

func interacte(player: CharacterBody3D, interaction_name: String = "") -> void:
	MESSAGETIME = 0.0
	if interaction_name.is_empty():
		for v: Interaction in interactions.values():
			if not v.available: continue
			v.interacte(player)
			return
	else:
		var inter: Interaction = interactions[interaction_name.to_lower()]
		if not inter: return
		inter.interacte(player)
