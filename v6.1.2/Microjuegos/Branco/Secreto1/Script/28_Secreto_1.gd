extends Node2D
signal finished(success)

@onready var gato = $Ekko
@onready var monticulo = $Monticulo
@onready var tiempo_restante = $TimerBarra
@onready var barra_tiempo = $BarraTiempo
@onready var label_instruccion = $TextoInstruccion

@export var duracion_juego := 5.0
var juego_activo := true
var contador_espacio := 0
var nivel_dificultad := 1

# Configurar dificultad del microjuego
func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	duracion_juego = Juego.obtener_duracion_por_dificultad(nivel)
	print("🎯 Secreto 1 configurado con dificultad ", nivel, " - Duración: ", duracion_juego, "s")

# Método alternativo para configurar duración directamente
func set_duracion_juego(duracion: float):
	duracion_juego = duracion
	print("⏱️ Duración del Secreto 1 configurada: ", duracion, "s")

func _ready():
	juego_activo = true
	
	# Configurar y arrancar el Timer
	tiempo_restante.wait_time = duracion_juego
	tiempo_restante.one_shot = true
	tiempo_restante.start()
	
	# Conectar señal del Timer (solo si no está ya conectada)
	if not tiempo_restante.timeout.is_connected(_on_TimerBarra_timeout):
		tiempo_restante.timeout.connect(_on_TimerBarra_timeout)

	barra_tiempo.max_value = duracion_juego
	barra_tiempo.value = duracion_juego

	label_instruccion.text = "¡Cava el montículo!"
	label_instruccion.visible = true

	monticulo.resetear()

func _process(delta):
	if not juego_activo:
		return

	barra_tiempo.value = tiempo_restante.time_left

	if gato.esta_cerca_de(monticulo):
		if Input.is_action_just_pressed("ui_accept"):
			contador_espacio += 1

			if contador_espacio >= 2:
				monticulo.cavar()
				contador_espacio = 0  # Reiniciar contador

				if monticulo.completado:
					finalizar_juego(true)
	else:
		# Si se aleja del montículo, reiniciar el contador para evitar que acumule clicks
		contador_espacio = 0

func _on_TimerBarra_timeout():
	if juego_activo:
		print("⏰ Tiempo terminado, perdiste")
		finalizar_juego(false)

func finalizar_juego(success: bool):
	if not juego_activo:
		return
	juego_activo = false
	tiempo_restante.stop()

	# Detener movimiento del gato
	gato.velocity = Vector2.ZERO
	gato.set_process(false)
	gato.set_physics_process(false)

	label_instruccion.text = "¡Ganaste!" if success else "¡Perdiste!"
	label_instruccion.visible = true

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", success)
