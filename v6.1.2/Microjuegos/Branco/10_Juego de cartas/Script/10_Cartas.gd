extends Node2D
signal finished(success)

# Variables de dificultad
var nivel_dificultad = 1
var duracion_juego := 5.0
var pulsaciones_por_carta := 5
var juego_activo := true
var pulsaciones_totales := 0
var cartas_lanzadas := 0

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			duracion_juego = 8.0
			pulsaciones_por_carta = 3
		2:
			duracion_juego = 7.0
			pulsaciones_por_carta = 4
		3:
			duracion_juego = 6.0
			pulsaciones_por_carta = 5
		4:
			duracion_juego = 5.0
			pulsaciones_por_carta = 6
		5:
			duracion_juego = 4.5
			pulsaciones_por_carta = 7
		6:
			duracion_juego = 4.0
			pulsaciones_por_carta = 8
		7:
			duracion_juego = 3.5
			pulsaciones_por_carta = 9
		8:
			duracion_juego = 3.0
			pulsaciones_por_carta = 10

	print("Nivel configurado:", nivel_dificultad)
	print("Duración juego:", duracion_juego)
	print("Pulsaciones por carta:", pulsaciones_por_carta)
	print("Pulsaciones totales necesarias:", pulsaciones_por_carta * 4)

func _ready():
	randomize()
	juego_activo = true
	pulsaciones_totales = 0
	cartas_lanzadas = 0

	mostrar_cartas()
	$PataJugadora.visible = true
	$LabelInstruccion.text = "¡Presiona [A] para lanzar las cartas!"
	$LabelInstruccion.visible = true

	# Configurar duración según dificultad (sin aleatorio)
	$BarraTiempo.max_value = duracion_juego
	$BarraTiempo.value = duracion_juego
	$BarraTiempo.visible = true

	$TimerJuego.wait_time = duracion_juego
	$TimerJuego.start()

func _input(event):
	if not juego_activo:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A:
			pulsaciones_totales += 1

			if pulsaciones_totales >= pulsaciones_por_carta * (cartas_lanzadas + 1):
				lanzar_carta()

func lanzar_carta():
	cartas_lanzadas += 1
	match cartas_lanzadas:
		1:
			$Carta.visible = false
		2:
			$Carta2.visible = false
		3:
			$Carta3.visible = false
		4:
			$Carta4.visible = false

	# Mostrar animación de mano lanzando carta
	$CartaAnimacion.visible = true
	await get_tree().create_timer(0.3).timeout
	$CartaAnimacion.visible = false

	if cartas_lanzadas == 4:
		victoria()

func victoria():
	juego_activo = false
	
	# 🔧 CORRECCIÓN: Detener el timer y ocultar la barra
	$TimerJuego.stop()
	$BarraTiempo.visible = false
	
	ocultar_todos()
	$LabelInstruccion.text = "¡Lanzaste todas las cartas!"
	$LabelInstruccion.visible = true
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", true)

func perder():
	juego_activo = false
	
	# 🔧 CORRECCIÓN: Detener el timer y ocultar la barra
	$TimerJuego.stop()
	$BarraTiempo.visible = false
	
	ocultar_todos()
	$LabelInstruccion.text = "¡Perdiste! Tiempo agotado."
	$LabelInstruccion.visible = true
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)

func _on_TimerJuego_timeout():
	if juego_activo:
		juego_activo = false  # Prevenir doble finalización

		if cartas_lanzadas >= 4:
			victoria()
		else:
			perder()

func _process(delta):
	# 🔧 CORRECCIÓN: Solo actualizar la barra si el juego está activo
	if juego_activo and $TimerJuego.time_left > 0:
		$BarraTiempo.value = $TimerJuego.time_left

func ocultar_todos():
	$PataJugadora.visible = false
	$Carta.visible = false
	$Carta2.visible = false
	$Carta3.visible = false
	$Carta4.visible = false
	$LabelInstruccion.visible = false

func mostrar_cartas():
	$Carta.visible = true
	$Carta2.visible = true
	$Carta3.visible = true
	$Carta4.visible = true
