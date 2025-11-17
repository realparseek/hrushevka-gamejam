extends RayCast3D

@export var ints_label: Label
@export var ints_background: ColorRect
@export var ints_selected: ColorRect
@export var crosshair: CenterContainer

@onready var hovered_obj: Interactable = null
@onready var hovered_interaction: int = -1
@onready var hovered_interactions: Array[String] = []

func _process(delta: float) -> void:
	_handle_crosshair(delta)
	var c: StaticBody3D = get_collider()
	if !c:
		_unhover_node()
		return
	
	_hover_node(c)
	_interacte_node()
	_handle_interaction_menu()

func _unhover_node() -> void:
	if hovered_obj:
		hovered_obj.unhover()
		hovered_obj = null
		hovered_interaction = -1
		ints_label.text = ''
	
	ints_background.visible = false
	ints_selected.visible = false

func _hover_node(body: StaticBody3D) -> void:
	if hovered_obj:
		return
	
	for n in body.get_children():
		if n.name.to_lower() != 'interactable':
			continue
		
		hovered_obj = n
		n.hover()
		hovered_interaction = 0
		hovered_interactions.assign(n.interactions.keys())
		for i in hovered_interactions:
			ints_label.text += hovered_obj.interactions[i].debug_name + '\n'
		ints_selected.visible = true
		ints_background.visible = true

func _interacte_node() -> void:
	if hovered_obj and Input.is_action_just_pressed("interact"):
		hovered_obj.interacte(hovered_interactions[hovered_interaction])

func _handle_crosshair(delta: float) -> void:
	if hovered_obj:
		crosshair.dot_radius = lerpf(crosshair.dot_radius, 3.0, delta*10)
		crosshair.dot_color = crosshair.dot_color.lerp(Color.GRAY, delta*8)
	else:
		crosshair.dot_radius = lerpf(crosshair.dot_radius, 1.0, delta*10)
		crosshair.dot_color = crosshair.dot_color.lerp(Color.WEB_GRAY, delta*8)

func _handle_interaction_menu() -> void:
	if !ints_selected.visible or !ints_background.visible:
		return
	
	ints_background.size.y = hovered_interactions.size() *(ints_label.label_settings.font_size*1.5 + ints_label.label_settings.line_spacing)
	ints_selected.size.y = (ints_label.label_settings.font_size*1.5 + ints_label.label_settings.line_spacing)
	ints_selected.position.y = 248.5 + hovered_interaction * (ints_label.label_settings.font_size*1.5 + ints_label.label_settings.line_spacing)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.is_pressed() or hovered_interaction < 0:
			return
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			hovered_interaction = wrap(hovered_interaction-1, 0, hovered_interactions.size())
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			hovered_interaction = wrap(hovered_interaction+1, 0, hovered_interactions.size())
