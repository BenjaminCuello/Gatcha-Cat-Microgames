extends Area2D

@onready var sprite = $LaserSprite

var speed = 1000.0  # Velocidad de movimiento del láser
var game_active = true  # Variable para controlar si el juego está activo

func _ready():
	# Configurar posición inicial del láser en el centro de la pantalla
	var screen_center = get_viewport().get_visible_rect().size / 2
	global_position = screen_center

func _process(delta):
	# Controlar movimiento solo si el juego está activo
	if not game_active:
		return
		
	# Controlar movimiento del láser con las teclas de flechas
	handle_arrow_keys(delta)

func handle_arrow_keys(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	
	# Mover el láser según la dirección y velocidad
	global_position += direction.normalized() * speed * delta
	
	# Limitar el movimiento dentro de los bordes de la pantalla
	var screen_rect = get_viewport().get_visible_rect()
	global_position.x = clamp(global_position.x, screen_rect.position.x, screen_rect.size.x)
	global_position.y = clamp(global_position.y, screen_rect.position.y, screen_rect.size.y)

func stop_movement():
	"""Detener completamente el movimiento del láser."""
	game_active = false
