extends CharacterBody2D

@onready var detection_area = $DetectionArea
@onready var sprite = $CatSprite

# Variables de dificultad
var nivel_dificultad = 1
var base_speed = 700.0  # Velocidad base
var speed = 700.0  # Velocidad actual según dificultad

var laser_target = null
var is_touching_laser = false
var can_move = true  # Control de movimiento

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	print("🐱 Cat - Configurando dificultad:", nivel)
	ajustar_velocidad_dificultad()

func ajustar_velocidad_dificultad():
	var velocidad_anterior = speed
	
	match nivel_dificultad:
		1:
			speed = base_speed  # 700
		2:
			speed = base_speed * 1.3  # 910
		3:
			speed = base_speed * 1.6  # 1120
		4:
			speed = base_speed * 2.0  # 1400
		5:
			speed = base_speed * 2.5  # 1750
		6:
			speed = base_speed * 3.0  # 2100
		7:
			speed = base_speed * 3.5  # 2450
		8:
			speed = base_speed * 4.0  # 2800

	print("🐱 Cat - Nivel:", nivel_dificultad)
	print("🐱 Cat - Velocidad anterior:", velocidad_anterior)
	print("🐱 Cat - Velocidad nueva:", speed)
	print("🐱 Cat - Multiplicador:", speed / base_speed, "x")
	print("🐱 Cat - Aumento:", int((speed/base_speed - 1) * 100), "%")

func _ready():
	print("🐱 Cat - _ready() iniciado")
	
	# Configurar collision layers
	collision_layer = 1     # El gato está en layer 1
	collision_mask = 0      # El gato NO colisiona físicamente con NADA
	
	# Verificar que los nodos existen antes de usarlos
	if detection_area:
		detection_area.area_entered.connect(_on_area_entered)
		detection_area.area_exited.connect(_on_area_exited)
	
	# Configurar sprite del gato solo si existe
	if sprite:
		sprite.modulate = Color.ORANGE
	
	print("🐱 Cat - _ready() completado, velocidad inicial:", speed)

func _physics_process(delta):
	# Solo moverse si puede moverse
	if can_move:
		move_towards_laser(delta)
		move_and_slide()

func move_towards_laser(delta):
	# Solo buscar láser si puede moverse
	if not can_move:
		velocity = Vector2.ZERO
		return
		
	# Encontrar el láser en la escena
	var laser = get_node("../Laser")
	if laser:
		# Calcular dirección hacia el láser
		var direction = (laser.global_position - global_position).normalized()
		
		# Usar velocidad según dificultad
		velocity = direction * speed
		
		# Debug ocasional para verificar velocidad
		if randf() < 0.01:  # 1% de las veces
			print("🐱 Cat - Velocidad actual aplicada:", speed)
		
		# Rotar hacia el láser (opcional, para que se vea más natural)
		if sprite:
			var angle = direction.angle()
			sprite.rotation = angle

# Función para detener el gato
func detener_movimiento():
	can_move = false
	velocity = Vector2.ZERO
	print("🐱 Cat - Movimiento detenido")

# Función para reanudar el movimiento
func reanudar_movimiento():
	can_move = true
	print("🐱 Cat - Movimiento reanudado con velocidad:", speed)

func _on_area_entered(area):
	if area.name == "Laser":
		laser_target = area
		is_touching_laser = true

func _on_area_exited(area):
	if area.name == "Laser":
		laser_target = null
		is_touching_laser = false
