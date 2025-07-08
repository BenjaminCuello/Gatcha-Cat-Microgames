extends Node2D

@export var amplitud: float = 600.0
@export var velocidad: float = 2.0

var posicion_inicial: Vector2

func _ready():
	posicion_inicial = position

func reset_posicion():
	position = posicion_inicial
	set_process(true)
	set_physics_process(true)

	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = false
	
func _process(delta):
	position.x = posicion_inicial.x + sin(Time.get_ticks_msec() / 1000.0 * velocidad) * amplitud
