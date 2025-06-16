extends CharacterBody2D

signal finished(success: bool)

var gravedad := 600.0
var impulso := -250.0
var velocidad := Vector2.ZERO
var velocidad_horizontal := 200.0
var tiempo_supervivencia := 0.0
var tiempo_maximo := 8.0  # Duración del microjuego

var juego_activo := true

func _ready():
	tiempo_supervivencia = 0.0
	juego_activo = true
	velocidad = Vector2.ZERO
	velocity = Vector2.ZERO  # ← importante también
	global_position = Vector2(100, 500)  # ← asegúrate de que reaparece en una posición segura


func _physics_process(delta):
	if not juego_activo:
		return

	# Movimiento vertical
	velocidad.y += gravedad * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocidad.y = impulso

	# Movimiento horizontal constante
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

	# Verificar si ha sobrevivido el tiempo máximo
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
