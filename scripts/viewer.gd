extends Control

@export var background: ColorRect
@export var scroll_cont: SmoothScrollContainer
@export var label: Label
@export var texture: TextureRect

@onready var is_viewing: bool = false
@onready var view_timer: float = 0.0

func _ready() -> void:
	is_viewing = false
	scroll_cont.visible = false
	texture.visible = false

func _process(delta: float) -> void: 
	_handle_viewing(delta)

func _handle_viewing(delta: float) -> void:
	if is_viewing:
		if view_timer != 1.0:
			view_timer = min(view_timer+delta, 1.0)
	else:
		if view_timer != 0.0:
			view_timer = max(view_timer-delta, 0.0)
	
	if view_timer == 1.0:
		scroll_cont.visible = true
		$background.color.a = lerpf($background.color.a, 0.7, delta*5)
		label.label_settings.font_color.a = lerpf(label.label_settings.font_color.a, 1.0, delta*7.0)
	else:
		$background.color.a = lerpf($background.color.a, 0.0, delta*5)
		label.label_settings.font_color.a = lerpf(label.label_settings.font_color.a, 0.0, delta*7.0)
	
	if view_timer == 0.0:
		scroll_cont.visible = false
	
func enter() -> void:
	is_viewing = true
	texture.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func exit() -> void:
	if texture.texture:
		texture.texture = null
	label.text = ''
	is_viewing = false
	texture.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
