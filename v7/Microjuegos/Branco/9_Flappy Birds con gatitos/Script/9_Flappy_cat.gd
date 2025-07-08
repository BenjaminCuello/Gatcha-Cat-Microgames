extends Node2D
signal microjuego_superado
signal microjuego_fallado

signal finished(success)

# Variables de dificultad
var nivel_dificultad = 1
var duracion_juego := 8.0  # 🔧 Duración según dificultad
var juego_activo := true

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	# Velocidad base: 200 px/s, tiempo base: 8s
	# Distancia base: 200 * 8 = 1600 px
	# Mantenemos la misma distancia relativa
	
	match nivel_dificultad:
		1:
			duracion_juego = 8.0    # Tiempo base
			# Velocidad base: 200 px/s
		2:
			duracion_juego = 5.33   # Tiempo reducido para 300 px/s
			# Velocidad: 300 px/s (+50% más rápido)
		3:
			duracion_juego = 4.57   # Tiempo reducido para 350 px/s
			# Velocidad: 350 px/s (+75% más rápido)
		4:
			duracion_juego = 4.0    # Tiempo reducido para 400 px/s
			# Velocidad: 400 px/s (+100% más rápido - DOBLE)
		5:
			duracion_juego = 3.56   # Tiempo reducido para 450 px/s
			# Velocidad: 450 px/s (+125% más rápido)
		6:
			duracion_juego = 3.2    # Tiempo reducido para 500 px/s
			# Velocidad: 500 px/s (+150% más rápido)
		7:
			duracion_juego = 2.91   # Tiempo reducido para 550 px/s
			# Velocidad: 550 px/s (+175% más rápido)
		8:
			duracion_juego = 2.67   # Tiempo reducido para 600 px/s
			# Velocidad: 600 px/s (+200% más rápido - TRIPLE)

	print("Nivel configurado:", nivel_dificultad)
	print("Duración del juego:", duracion_juego, "segundos")

func _ready():
	juego_activo = true
	$GatitoVolador.finished.connect(_on_GatitoVolador_finished)

	$LabelInstruccion.text = "¡Presiona espacio para volar!"
	$LabelInstruccion.visible = true

	# Configurar tiempo según dificultad
	$BarraTiempo.max_value = duracion_juego
	$BarraTiempo.value = duracion_juego
	$BarraTiempo.visible = true

	$TimerJuego.wait_time = duracion_juego
	$TimerJuego.start()
	
	# Configurar dificultad del gato volador
	if $GatitoVolador.has_method("configurar_dificultad"):
		$GatitoVolador.configurar_dificultad(nivel_dificultad)

func _process(delta):
	if juego_activo and $TimerJuego.time_left > 0:
		$BarraTiempo.value = $TimerJuego.time_left

func _on_TimerJuego_timeout():
	if juego_activo:
		$GatitoVolador.ganar()

func _on_GatitoVolador_finished(success):
	if not juego_activo:
		return  # Ya terminó, ignorar
	juego_activo = false

	if success:
		$LabelInstruccion.text = "¡Ganaste! Sobreviviste %.1f segundos." % duracion_juego
		emit_signal("microjuego_superado")  # NUEVO
	else:
		$LabelInstruccion.text = "¡Perdiste! Tocaste un árbol."
		emit_signal("microjuego_fallado")  # NUEVO

	$LabelInstruccion.visible = true

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", success)
