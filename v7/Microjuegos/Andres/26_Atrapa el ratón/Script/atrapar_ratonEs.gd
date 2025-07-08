extends Node2D
signal microjuego_superado
signal microjuego_fallado

signal finished(success)

@onready var cat = $pataGato/CollisionShape2D
@onready var mouse = $SpriteRaton
@onready var jugando = true
@export var duracion_juego = 5.0

# Variables para la dificultad
var nivel_dificultad = 1
var velocidad_raton = 1.0

func _process(delta):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		return  # Ignora ESC

	#print("a")
	if Input.is_key_pressed(KEY_SPACE) and jugando == true:
		agarrarRaton()
		
	if $TiempoRestante.time_left >= 0:
		$barraDeTiempo.value = $TiempoRestante.time_left

# Función para configurar la dificultad (llamada desde el sistema principal)
func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

# Función para ajustar los parámetros según el nivel
func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:  # Nivel 1
			duracion_juego = 3.0
			velocidad_raton = 1.0
		2:  # Nivel 2
			duracion_juego = 2.0
			velocidad_raton = 1.3
		3:  # Nivel 3
			duracion_juego = 1.5
			velocidad_raton = 1.6
		4:  # Nivel 4
			duracion_juego = 1.2
			velocidad_raton = 1.9
		5:  # Nivel 5
			duracion_juego = 1.0
			velocidad_raton = 2.2
		6:  # Nivel 6
			duracion_juego = 0.8
			velocidad_raton = 2.5
		7:  # Nivel 7
			duracion_juego = 0.5
			velocidad_raton = 2.8
		8:  # Nivel 8 (Máximo)
			duracion_juego = 0.3
			velocidad_raton = 3.0

func _ready():
	randomize()
	
	# Configurar dificultad por defecto (será sobrescrita por el sistema principal)
	ajustar_parametros_dificultad()

	await get_tree().create_timer(0.05).timeout
	#por alguna razón si no te mueves por una partida entera, la siguiente vez que jueges
	#la pata de gato desaparece, por lo que esto es para ponerla en su lugar (no funciona sin el timer)
	$pataGato.position = Vector2(0, 0)
	await get_tree().create_timer(1.0).timeout

	$SpriteRaton/AnimationPlayer.play("RESET")
	# Aplicar la velocidad del ratón según la dificultad
	$SpriteRaton/AnimationPlayer.speed_scale = velocidad_raton
	$Instruccion.visible = false

	$barraDeTiempo.max_value = duracion_juego
	$barraDeTiempo.value = duracion_juego

	$TiempoRestante.start(duracion_juego)

func agarrarRaton():
	var distancia = cat.global_position.distance_to(mouse.global_position)
	var radioAtrapar = 120
	#print("Distancia entre gato y ratón: ", distancia)

	if distancia <= radioAtrapar:
		$Instruccion.text = "¡Lo atrapaste!"
		$Instruccion.visible = true
		print("¡Lo atrapaste!")
		emit_signal("finished", true)
		emit_signal("microjuego_superado")

		jugando = false
		$TiempoRestante.stop()
	else:
		print("No le diste")

func _on_timer_timeout():
	jugando = false
	emit_signal("finished", false)
	emit_signal("microjuego_fallado")

	print("juego terminado por tiempo, perdiste")
