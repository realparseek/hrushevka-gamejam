extends Node
class_name Interactable

var interactions: Dictionary[String,Interaction] = {}

func _ready() -> void:
	if len(interactions):
		interactions.clear()
	
	for c in get_children():
		if c is Interaction:
			interactions[c.name.to_lower()] = c

func interacte(interaction_name: String = "") -> void:
	if interaction_name.is_empty():
		for v: Interaction in interactions.values():
			if not v.available: continue
			v.interacte()
			return
		return
	var inter: Interaction = interactions[interaction_name.to_lower()]
	if not inter: return
	inter.interacte()
