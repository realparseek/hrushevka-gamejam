extends CollisionShape3D

@onready var audio_player = get_node("../audio")

func _ready():
	# Родитель (поменять если родитель другой)
	var parent = get_parent()
	if parent is RigidBody3D:
		parent.body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node):
	# Звук
	if audio_player:
		audio_player.play()
