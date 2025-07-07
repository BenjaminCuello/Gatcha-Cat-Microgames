extends CharacterBody2D

@onready var detection_area = $DetectionArea
@onready var sprite = $CatSprite

var speed = 700.0  # Velocidad aumentada para movimiento rápido
var laser_target = null
var is_touching_laser = false

func _ready():
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

func _physics_process(delta):
	# El gato siempre persigue el láser agresivamente
	move_towards_laser(delta)
	move_and_slide()

func move_towards_laser(delta):
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

func _on_area_entered(area):
	if area.name == "Laser":
		laser_target = area
		is_touching_laser = true

func _on_area_exited(area):
	if area.name == "Laser":
		laser_target = null
		is_touching_laser = false
