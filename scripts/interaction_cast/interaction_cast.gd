extends Node
class_name InteractionCast

@export var fps: FPSMovement
@export var inventory: Inventory
@export var raycast: RayCast3D
@export var icon_sprite: Sprite3D
@export var crosshair_rect: ColorRect
@export var pickup_sound: AudioStreamPlayer
@export var denied_sound: AudioStreamPlayer
@export var icon_interacte: Texture2D
@export var icon_drag: Texture2D

var ORIGINAL_MSENSETIVITY: float = 0.0
var PICKED_HOVERABLE: Hoverable = null
var PICKED_DRAGGABLE: Draggable = null
var ICON_POS: Vector3 = Vector3.ZERO

func _ready() -> void:
	if fps: 
		ORIGINAL_MSENSETIVITY = fps.mouse_sensetivity

func _process(_delta: float) -> void:
	if not Input.is_action_pressed("item_interacte") and PICKED_DRAGGABLE:
		if fps: fps.mouse_sensetivity = ORIGINAL_MSENSETIVITY
		PICKED_DRAGGABLE.stop_dragging()
		PICKED_DRAGGABLE = null
	
	#var coll: StaticBody3D = raycast.get_collider()
	var coll = raycast.get_collider()
	if not coll and not PICKED_DRAGGABLE:
		if PICKED_HOVERABLE:
			PICKED_HOVERABLE.unhover()
			PICKED_HOVERABLE = null
		hide_icon()
		return
	
	var hoverable: Hoverable
	var pickable: Pickable
	var draggable: Draggable
	var interactable: Interactable
	
	if not PICKED_DRAGGABLE:
		for c in coll.get_children():
			if c is Hoverable: hoverable = c
			if c is Pickable: pickable = c
			if c is Draggable: draggable = c
			if c is Interactable: interactable = c
	
	if hoverable:
		if PICKED_HOVERABLE and PICKED_HOVERABLE != hoverable:
			PICKED_HOVERABLE.unhover()
		hoverable.hover()
		PICKED_HOVERABLE = hoverable
		ICON_POS = coll.global_position if not hoverable.icon_pos else hoverable.icon_pos.global_position
	
	if pickable and inventory:
		if Input.is_action_just_pressed("item_pickup"):
			if not inventory.add_pickable(pickable):
				if denied_sound.playing:
					denied_sound.stop()
				denied_sound.play()
			else:
				if coll is RigidBody3D and coll.freeze:
					coll.freeze = false
				coll.queue_free()
				if pickup_sound.playing:
					pickup_sound.stop()
				pickup_sound.play()

	if draggable:
		if Input.is_action_just_pressed("item_interacte"):
			if fps: fps.mouse_sensetivity = ORIGINAL_MSENSETIVITY/4.0
			PICKED_DRAGGABLE = draggable
			PICKED_DRAGGABLE.start_dragging()
			show_drag_icon()
	
	if interactable:
		if Input.is_action_just_pressed("item_interacte"):
			interactable.interacte()
	
	if PICKED_DRAGGABLE: show_drag_icon()
	else: show_interacte_icon()

func show_interacte_icon() -> void:
	if not icon_sprite: return
	icon_sprite.global_position = ICON_POS
	icon_sprite.texture = icon_interacte
	icon_sprite.visible = true
	crosshair_rect.visible = false

func show_drag_icon() -> void:
	if not icon_sprite: return
	icon_sprite.global_position = ICON_POS
	icon_sprite.texture = icon_drag
	icon_sprite.visible = true
	crosshair_rect.visible = false

func hide_icon() -> void:
	if not icon_sprite: return
	icon_sprite.visible = false
	crosshair_rect.visible = true
