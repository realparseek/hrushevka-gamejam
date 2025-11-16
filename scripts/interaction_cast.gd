extends RayCast3D

@onready var hovered_obj: Interactable = null

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

func _hover_node(body: StaticBody3D) -> void:
	if hovered_obj:
		return
	
	for n in body.get_children():
		if n.name.to_lower() != 'interactable':
			continue
		
		hovered_obj = n
		hovered_obj.hover()

func _interacte_node() -> void:
	if hovered_obj and Input.is_action_just_pressed("interact"):
		hovered_obj.interacte("switchon")
