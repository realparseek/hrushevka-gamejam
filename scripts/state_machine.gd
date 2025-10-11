extends Node

@export var initial_state : State = null

@onready var states : Dictionary = {}
@onready var current_state : State = null

func _ready() -> void:
	for state in get_children():
		if state is not State:
			continue
		
		states[state.name.to_lower()] = state
		state.Transitioned.connect(_on_state_transitioned)
		
	if !initial_state:
		return	
	if !states[initial_state.name.to_lower()]:
		return
		
	initial_state.Transitioned.emit(initial_state.name.to_lower(), initial_state)

func _process(delta: float) -> void:
	if !current_state:
		return
	current_state.update(delta)
	
func _physics_process(delta: float) -> void:
	if !current_state:
		return
	current_state.physics_update(delta)

func _on_state_transitioned(state_name : String, state : State) -> void:
	var new_state: State = states[state_name.to_lower()]
	
	if !new_state:
		return
	if state:
		state.exit()
		
	new_state.enter()
	current_state = new_state
