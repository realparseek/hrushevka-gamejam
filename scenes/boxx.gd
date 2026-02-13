extends RigidBody3D

@export var push_force: float = 2.5           # Сила толчка от игрока
@export var rotation_locked: bool = true      # Блокировка вращения (уникальное имя)
@export var continuous_cd_enabled: bool = true # Непрерывное обнаружение коллизий

func _ready():
	# --- Применяем настройки к наследуемым свойствам ---
	lock_rotation = rotation_locked
	continuous_cd = continuous_cd_enabled
	
	# Обязательно для контактов (Jolt работает стабильнее, если контакты включены)
	contact_monitor = true
	max_contacts_reported = 4
	
	# Коробка начинает в спячке — Jolt разбудит при необходимости
	sleeping = true

# ------------------------------------------------------------
# Публичный метод: толкаем ТОЛЬКО себя (Jolt сам обработает стопки)
func push(direction: Vector3, strength: float = push_force):
	var flat_dir = direction
	flat_dir.y = 0.0
	if flat_dir.length() == 0:
		return
	
	flat_dir = flat_dir.normalized()
	
	# Плавное ускорение — apply_central_force, НЕ импульс
	apply_central_force(flat_dir * strength)
	
	# Пробуждаем коробку
	sleeping = false
