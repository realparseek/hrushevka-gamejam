extends RayCast3D

@export var ints_label: Label
@export var crosshair: CenterContainer

@onready var hovered_obj: Interactable = null
@onready var hovered_interaction: String = ''

func _process(delta: float) -> void:
	_handle_crosshair(delta)
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

func _handle_crosshair(delta: float) -> void:
	if hovered_obj:
		crosshair.dot_radius = lerpf(crosshair.dot_radius, 3.0, delta*10)
		crosshair.dot_color = crosshair.dot_color.lerp(Color.GRAY, delta*8)
	else:
		crosshair.dot_radius = lerpf(crosshair.dot_radius, 1.0, delta*10)
		crosshair.dot_color = crosshair.dot_color.lerp(Color.WEB_GRAY, delta*8)
