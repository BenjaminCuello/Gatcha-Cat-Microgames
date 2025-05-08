extends Node2D
signal finished(success)

var lado_actual := ""  # izquierda o derecha
var esperando := false
var duracion_juego := 5.0
var juego_activo := true


func _ready():
	juego_activo = true
	# Estado inicial
	ocultar_todos()
	$GatoEquilibrio.visible = true
	$TextoInstruccion.text = "¡Atento!"
	$TextoInstruccion.visible = true

	await get_tree().create_timer(1.0).timeout

	$TextoInstruccion.visible = false
	$BarraTiempo.max_value = duracion_juego
	$BarraTiempo.value = duracion_juego
	$BarraTiempo.visible = true

	$TimerJuego.wait_time = duracion_juego
	$TimerJuego.start()
	
	nueva_instruccion()

func nueva_instruccion():
	if not juego_activo:
		return
	if esperando:
		perder()
		return

	lado_actual = ["izquierda", "derecha"].pick_random()
	esperando = true
	ocultar_todos()

	if lado_actual == "izquierda":
		$gato_izq.visible = true
		$TextoInstruccion.text = "¡Presiona →!"
	else:
		$gato_der.visible = true
		$TextoInstruccion.text = "¡Presiona ←!"

	$TextoInstruccion.visible = true

	$TimerRespuesta.start()

func _input(event):
	if not esperando:
		return
	if event is InputEventKey and event.pressed:
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
	# Esperar un poco antes de la próxima instrucción
	$TimerCambio.start()

func perder():
	esperando = false
	juego_activo = false
	$TimerJuego.stop()
	$TimerRespuesta.stop()
	$TimerCambio.stop()
	ocultar_todos()
	$gato_se_cae.visible = true
	await get_tree().create_timer(0.6).timeout
	emit_signal("finished", false)

func _on_TimerRespuesta_timeout():
	if esperando:
		perder()

func _on_TimerCambio_timeout():
	nueva_instruccion()

func _on_TimerJuego_timeout():
	juego_activo = false
	$TimerRespuesta.stop()
	$TimerCambio.stop()
	emit_signal("finished", true)

func _process(delta):
	if $TimerJuego.time_left > 0:
		$BarraTiempo.value = $TimerJuego.time_left

func ocultar_todos():
	$GatoEquilibrio.visible = false
	$gato_izq.visible = false
	$gato_der.visible = false
	$gato_se_cae.visible = false
	$TextoInstruccion.visible = false
