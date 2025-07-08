extends CharacterBody2D

signal finished(success: bool)

# Variables de dificultad
var nivel_dificultad = 1
var velocidad_horizontal := 200.0  # 🔧 Velocidad según dificultad
var tiempo_maximo := 8.0          # 🔧 Tiempo según dificultad

var gravedad := 600.0
var impulso := -250.0
var velocidad := Vector2.ZERO
var tiempo_supervivencia := 0.0

var juego_activo := true

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			velocidad_horizontal = 200.0
			tiempo_maximo = 8.0
		2:
			velocidad_horizontal = 300.0  # +50% más rápido
			tiempo_maximo = 5.33
		3:
			velocidad_horizontal = 350.0  # +75% más rápido
			tiempo_maximo = 4.57
		4:
			velocidad_horizontal = 400.0  # +100% más rápido (DOBLE)
			tiempo_maximo = 4.0
		5:
			velocidad_horizontal = 450.0  # +125% más rápido
			tiempo_maximo = 3.56
		6:
			velocidad_horizontal = 500.0  # +150% más rápido
			tiempo_maximo = 3.2
		7:
			velocidad_horizontal = 550.0  # +175% más rápido
			tiempo_maximo = 2.91
		8:
			velocidad_horizontal = 600.0  # +200% más rápido (TRIPLE)
			tiempo_maximo = 2.67

	print("🐱 Gato Volador - Nivel:", nivel_dificultad)
	print("🐱 Gato Volador - Velocidad horizontal:", velocidad_horizontal, "px/s")
	print("🐱 Gato Volador - Aumento de velocidad:", int((velocidad_horizontal/200.0 - 1) * 100), "%")
	print("🐱 Gato Volador - Tiempo máximo:", tiempo_maximo, "segundos")
	print("🐱 Gato Volador - Distancia total:", int(velocidad_horizontal * tiempo_maximo), "px")

func _ready():
	tiempo_supervivencia = 0.0
	juego_activo = true
	velocidad = Vector2.ZERO
	velocity = Vector2.ZERO
	global_position = Vector2(100, 500)

func _physics_process(delta):
	if not juego_activo:
		return

	# Movimiento vertical
	velocidad.y += gravedad * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocidad.y = impulso

	# Movimiento horizontal según dificultad (MUCHO más rápido)
	velocidad.x = velocidad_horizontal

	velocity = velocidad
	var colision = move_and_collide(velocity * delta)
	if colision and colision.get_collider().is_in_group("ObstaculoVolador"):
		perder()

	# Limitar dentro del área visible
	var limite_superior = 0
	var limite_inferior = get_viewport_rect().size.y
	global_position.y = clamp(global_position.y, limite_superior, limite_inferior)

	if global_position.y >= limite_inferior:
		perder()

	# Verificar supervivencia con tiempo configurado
	tiempo_supervivencia += delta
	if tiempo_supervivencia >= tiempo_maximo:
		ganar()

func perder():
	if not juego_activo:
		return
	juego_activo = false
	emit_signal("finished", false)

func ganar():
	if not juego_activo:
		return
	juego_activo = false
	emit_signal("finished", true)
