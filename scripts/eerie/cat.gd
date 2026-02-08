extends Node3D

@onready var player: CharacterBody3D = $'../../player_fps'

func _physics_process(_delta: float) -> void:
	var player_pos: Vector3 = player.global_position
	look_at(player_pos, Vector3.UP)
	rotate_y(deg_to_rad(180))
	rotation.x = 0.0
