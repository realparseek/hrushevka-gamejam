extends RayCast3D

@export var ints_label: Label

@onready var hovered_obj: Interactable = null
@onready var hovered_interaction: String = ''

func _process(delta: float) -> void:
	var c: StaticBody3D = get_collider()
	if !c:
		_unhover_node()
		return
	
	_hover_node(c)
	_interacte_node()

func _unhover_node() -> void:
	if hovered_obj:
		hovered_obj.unhover()
		hovered_obj = null
		hovered_interaction = ''
		ints_label.text = ''

func _hover_node(body: StaticBody3D) -> void:
	if hovered_obj:
		return
	
	for n in body.get_children():
		if n.name.to_lower() != 'interactable':
			continue
		
		hovered_obj = n
		n.hover()
		hovered_interaction = n.interactions.keys()[0]
		for i in n.interactions.values():
			ints_label.text += i.debug_name + '\n'

func _interacte_node() -> void:
	if hovered_obj and Input.is_action_just_pressed("interact"):
		hovered_obj.interacte(hovered_interaction)
