extends CharacterBody2D

@onready var detection_area = $DetectionArea
@onready var sprite = $CatSprite

var speed = 700.0
var laser_target = null
var is_touching_laser = false
var game_active = true  # Nueva variable para controlar si el juego está activo
var initial_position = Vector2.ZERO  # Guardar posición inicial

func _ready():
	# Guardar posición inicial para reset
	initial_position = global_position
	
	# Verificar que los nodos existen antes de usarlos
	if detection_area:
		detection_area.area_entered.connect(_on_area_entered)
		detection_area.area_exited.connect(_on_area_exited)
	
	# Configurar sprite del gato solo si existe
	if sprite:
		sprite.modulate = Color.ORANGE

func _physics_process(delta):
	# Solo mover si el juego está activo
	if not game_active:
		velocity = Vector2.ZERO
		return
		
	# El gato siempre persigue el láser agresivamente
	move_towards_laser(delta)
	move_and_slide()

func move_towards_laser(delta):
	# Solo mover si el juego está activo
	if not game_active:
		return
		
	# Encontrar el láser en la escena
	var laser = get_node("../Laser")
	if laser:
		# Calcular dirección hacia el láser
		var direction = (laser.global_position - global_position).normalized()
		
		# Movimiento directo y rápido hacia el láser
		velocity = direction * speed
		
		# Rotar hacia el láser (opcional, para que se vea más natural)
		if sprite:
			var angle = direction.angle()
			sprite.rotation = angle
	
	# Limitar movimiento dentro de los bordes de la pantalla
	var screen_rect = get_viewport().get_visible_rect()
	global_position.x = clamp(global_position.x, screen_rect.position.x, screen_rect.size.x)
	global_position.y = clamp(global_position.y, screen_rect.position.y, screen_rect.size.y)

func _on_area_entered(area):
	if area.name == "Laser":
		laser_target = area
		is_touching_laser = true

func _on_area_exited(area):
	if area.name == "Laser":
		laser_target = null
		is_touching_laser = false

func stop_movement():
	"""Detener completamente el movimiento del gato."""
	game_active = false
	velocity = Vector2.ZERO
	# Detener cualquier animación o rotación
	if sprite:
		sprite.rotation = 0

func reset_cat():
	"""Resetear posición y estado del gato."""
	game_active = true
	global_position = initial_position
	velocity = Vector2.ZERO
	is_touching_laser = false
	laser_target = null
	if sprite:
		sprite.rotation = 0
		sprite.modulate = Color.ORANGE
