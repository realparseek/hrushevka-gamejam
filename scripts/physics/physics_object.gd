extends RigidBody3D
class_name PhysicsObject

enum Kind { DEFAULT, BALL, LONG, HEAVY }

@export var kind: Kind = Kind.DEFAULT:
	set(value):
		kind = value
		if is_inside_tree():
			_apply_kind()

@export var max_horizontal_speed: float = 0.0
@export var horizontal_damping: float = 0.0

func _ready() -> void:
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = maxi(max_contacts_reported, 8)
	can_sleep = true
	_apply_kind()

func _physics_process(delta: float) -> void:
	if max_horizontal_speed > 0.0:
		var horiz: Vector2 = Vector2(linear_velocity.x, linear_velocity.z)
		if horiz.length() > max_horizontal_speed:
			horiz = horiz.normalized() * max_horizontal_speed
			linear_velocity.x = horiz.x
			linear_velocity.z = horiz.y
	if horizontal_damping > 0.0:
		var f: float = clampf(1.0 - horizontal_damping * delta, 0.0, 1.0)
		linear_velocity.x *= f
		linear_velocity.z *= f

func _apply_kind() -> void:
	match kind:
		Kind.BALL:
			if not is_in_group("ball"):
				add_to_group("ball")
			if max_horizontal_speed <= 0.0:
				max_horizontal_speed = 5.0
			if horizontal_damping <= 0.0:
				horizontal_damping = 0.25
			if angular_damp <= 0.0:
				angular_damp = 0.3
		Kind.LONG:
			if not is_in_group("long_object"):
				add_to_group("long_object")
		Kind.HEAVY:
			pass
		_:
			pass
