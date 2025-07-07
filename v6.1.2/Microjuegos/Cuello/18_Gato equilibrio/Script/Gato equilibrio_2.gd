extends Node2D
signal finished(success)

var lado_actual := ""  # izquierda o derecha
var esperando := false
var juego_activo := true

# Variables de dificultad
var nivel_dificultad = 1
var duracion_juego := 5.0
var tiempo_respuesta := 1.0
var tiempo_cambio := 0.5

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			duracion_juego = 5.0
			tiempo_respuesta = 1.0
			tiempo_cambio = 0.5
		2:
			duracion_juego = 6.0
			tiempo_respuesta = 0.8
			tiempo_cambio = 0.4
		3:
			duracion_juego = 7.0
			tiempo_respuesta = 0.6
			tiempo_cambio = 0.3
		4:
			duracion_juego = 8.0
			tiempo_respuesta = 0.5
			tiempo_cambio = 0.25
		5:
			duracion_juego = 9.0
			tiempo_respuesta = 0.4
			tiempo_cambio = 0.2
		6:
			duracion_juego = 10.0
			tiempo_respuesta = 0.3
			tiempo_cambio = 0.15
		7:
			duracion_juego = 11.0
			tiempo_respuesta = 0.25
			tiempo_cambio = 0.1
		8:
			duracion_juego = 12.0
			tiempo_respuesta = 0.2
			tiempo_cambio = 0.08

	print("Nivel configurado:", nivel_dificultad)
	print("Duración juego:", duracion_juego)
	print("Tiempo respuesta:", tiempo_respuesta)
	print("Tiempo cambio:", tiempo_cambio)

func _ready():
	randomize()
	juego_activo = true
	ocultar_todos()
	$GatoEquilibrio.visible = true

	$LabelControles.visible = true
	$LabelInstruccion.text = "¡Atento!"
	$LabelInstruccion.visible = true
	await get_tree().create_timer(1.0).timeout
	$LabelInstruccion.visible = false

	# Configurar duración según dificultad (no aleatoria)
	$BarraTiempo.max_value = duracion_juego
	$BarraTiempo.value = duracion_juego
	$BarraTiempo.visible = true

	$TimerJuego.wait_time = duracion_juego
	$TimerJuego.start()

	# Configurar timers según dificultad
	$TimerRespuesta.wait_time = tiempo_respuesta
	$TimerCambio.wait_time = tiempo_cambio

	nueva_instruccion()

func nueva_instruccion():
	if not juego_activo:
		return
	if esperando:
		perder()
		return

	# ❗ Evitar nueva flecha si queda poco tiempo
	if $TimerJuego.time_left <= 0.5:
		return

	lado_actual = ["izquierda", "derecha"].pick_random()
	esperando = true
	ocultar_todos()

	if lado_actual == "izquierda":
		$gato_izq.visible = true
		$LabelDireccion.text = "[→]"
	else:
		$gato_der.visible = true
		$LabelDireccion.text = "[←]"

	$LabelDireccion.visible = true
	
	# Configurar timer de respuesta según dificultad
	$TimerRespuesta.wait_time = tiempo_respuesta
	$TimerRespuesta.start()

func _input(event):
	if not esperando:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return

		if lado_actual == "izquierda" and event.keycode == KEY_RIGHT:
			acertar()
		elif lado_actual == "derecha" and event.keycode == KEY_LEFT:
			acertar()
		else:
			perder()

func acertar():
	esperando = false
	$TimerRespuesta.stop()
	ocultar_todos()
	$GatoEquilibrio.visible = true
	
	# Configurar timer de cambio según dificultad
	$TimerCambio.wait_time = tiempo_cambio
	$TimerCambio.start()

func perder():
	esperando = false
	juego_activo = false
	$TimerJuego.stop()
	$TimerRespuesta.stop()
	$TimerCambio.stop()
	$BarraTiempo.visible = false
	ocultar_todos()
	$gato_se_cae.visible = true
	$LabelInstruccion.text = "¡Perdiste!"
	$LabelInstruccion.visible = true
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)

func victoria():
	juego_activo = false
	$BarraTiempo.visible = false
	ocultar_todos()
	$LabelInstruccion.text = "¡Mantuviste el equilibrio!"
	$LabelInstruccion.visible = true
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", true)

func _on_TimerRespuesta_timeout():
	if esperando:
		perder()

func _on_TimerCambio_timeout():
	nueva_instruccion()

func _on_TimerJuego_timeout():
	if esperando:
		perder()
	else:
		victoria()

func _process(delta):
	if juego_activo and $TimerJuego.time_left > 0:
		$BarraTiempo.value = $TimerJuego.time_left

func ocultar_todos():
	$GatoEquilibrio.visible = false
	$gato_izq.visible = false
	$gato_der.visible = false
	$gato_se_cae.visible = false
	$LabelInstruccion.visible = false
	$LabelDireccion.visible = false
