extends Node3D

func _ready():
	# Создаём систему частиц
	var particles = GPUParticles3D.new()
	particles.name = "DustParticles"
	
	# Основные параметры
	particles.amount = 400
	particles.lifetime = 5.0
	particles.explosiveness = 0.0
	particles.one_shot = false
	particles.preprocess = 2.0
	
	# Устанавливаем форму эмиссии: 1 = сфера (Sphere)
	particles.set_emission_shape(1)  # метод вместо прямого присвоения
	particles.emission_shape_offset = Vector3.ZERO
	particles.emission_shape_scale = Vector3(0.35, 0.35, 0.35)
	
	# Создаём процессный материал
	var material = ParticleProcessMaterial.new()
	
	# Направление и скорость — почти ноль, чтобы пыль "стояла"
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.initial_velocity_min = 0.02
	material.initial_velocity_max = 0.1
	material.gravity = Vector3(0, 0, 0)
	material.damping = 0.0
	
	# Размер пылинок
	material.scale_min = 0.012
	material.scale_max = 0.035
	
	# Цвет (серовато-белый, полупрозрачный)
	material.color = Color(0.9, 0.85, 0.8, 0.4)
	
	# Турбулентность — лёгкое "летание туда-сюда"
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 2.5
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	
	var noise_texture = NoiseTexture2D.new()
	noise_texture.noise = noise
	noise_texture.width = 128
	noise_texture.height = 128
	
	material.turbulence_enabled = true
	material.turbulence_noise_strength = 0.25
	material.turbulence_noise_scale = 1.2
	material.turbulence_initial_velocity_randomness = 0.5
	material.turbulence_noise_texture = noise_texture
	
	# Применяем материал
	particles.process_material = material
	
	# Добавляем в сцену
	add_child(particles)
	
	# Располагаем под лампочкой (подберите высоту под вашу сцену)
	particles.position = Vector3(0, 1.5, 0)
