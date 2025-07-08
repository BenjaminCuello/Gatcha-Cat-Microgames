extends Node2D
signal microjuego_superado
signal microjuego_fallado

signal finished(success)

enum GatoEstado { BASE, IZQUIERDA, DERECHA }

var estado_objetivo: GatoEstado
var estado_actual: GatoEstado = GatoEstado.BASE

# Variables de dificultad
var nivel_dificultad = 1
var tiempo_juego = 5.0
var tiempo_cambio_foto = 1.0

# Variables de control
var juego_terminado = false
var puede_cambiar_foto = true

@onready var gato_base = $GatoBase
@onready var gato_foto = $GatoFoto
@onready var texto = $TextoInstruccion
@onready var controles = $TextoControles
@onready var barra = $BarraTiempo
@onready var timer_barra = $TimerBarra
@onready var timer_cambio_foto = $TimerCambioFoto

# Texturas del jugador (GatoBase)
var texturas_base := {
	GatoEstado.BASE: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/Pure.png"),
	GatoEstado.IZQUIERDA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureIzquierda.png"),
	GatoEstado.DERECHA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureDerecha.png")
}

# Texturas de la foto (GatoFoto)
var texturas_foto := {
	GatoEstado.BASE: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureFoto.png"),
	GatoEstado.IZQUIERDA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureFotoIzquierda.png"),
	GatoEstado.DERECHA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureFotoDerecha.png")
}

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			tiempo_juego = 6.0
			tiempo_cambio_foto = 1.0
		2:
			tiempo_juego = 5.5
			tiempo_cambio_foto = 0.8
		3:
			tiempo_juego = 5.0
			tiempo_cambio_foto = 0.6
		4:
			tiempo_juego = 4.5
			tiempo_cambio_foto = 0.5
		5:
			tiempo_juego = 4.0
			tiempo_cambio_foto = 0.4
		6:
			tiempo_juego = 3.5
			tiempo_cambio_foto = 0.3
		7:
			tiempo_juego = 3.0
			tiempo_cambio_foto = 0.2
		8:
			tiempo_juego = 2.5
			tiempo_cambio_foto = 0.1

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo juego:", tiempo_juego)
	print("Tiempo cambio foto:", tiempo_cambio_foto)

func _ready():
	texto.text = "¡Haz match con la foto!"
	texto.visible = true
	controles.text = "Usá ← / → / ↑ para moverte"
	controles.visible = true

	# Configurar barra de tiempo con la dificultad
	barra.max_value = tiempo_juego
	barra.value = tiempo_juego
	barra.visible = true

	randomize()
	estado_objetivo = GatoEstado.values().pick_random()
	actualizar_foto()
	actualizar_gato()

	# Configurar timers con la dificultad
	timer_barra.wait_time = tiempo_juego
	timer_cambio_foto.wait_time = tiempo_cambio_foto
	
	timer_barra.start()
	timer_cambio_foto.start()

func _input(event):
	# Solo permitir movimiento si el juego NO ha terminado
	if not juego_terminado and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				estado_actual = GatoEstado.IZQUIERDA
			KEY_RIGHT:
				estado_actual = GatoEstado.DERECHA
			KEY_UP:
				estado_actual = GatoEstado.BASE
		actualizar_gato()

func actualizar_foto():
	gato_foto.texture = texturas_foto[estado_objetivo]

func actualizar_gato():
	gato_base.texture = texturas_base[estado_actual]

func _on_TimerCambioFoto_timeout():
	# Solo cambiar foto si está permitido (no en los últimos 0.1 segundos)
	if puede_cambiar_foto:
		estado_objetivo = GatoEstado.values().pick_random()
		actualizar_foto()

func _on_TimerBarra_timeout():
	# Marcar que el juego terminó (bloquear movimiento)
	juego_terminado = true
	
	# Detener todos los timers
	timer_cambio_foto.stop()
	
	# Ocultar elementos de UI
	barra.visible = false
	texto.visible = false
	controles.visible = false

	# Evaluar resultado
	if estado_actual == estado_objetivo:
		texto.text = "¡Correcto!"
		emit_signal("microjuego_superado")  # NUEVO
		emit_signal("finished", true)
	else:
		texto.text = "¡Fallaste!"
		emit_signal("microjuego_fallado")  # NUEVO
		emit_signal("finished", false)

	texto.visible = true


func _process(delta):
	if timer_barra.time_left > 0:
		barra.value = timer_barra.time_left
		
		# Bloquear cambio de foto en los últimos 0.1 segundos
		if timer_barra.time_left <= 0.1:
			puede_cambiar_foto = false
		else:
			puede_cambiar_foto = true
