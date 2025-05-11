extends Node2D

signal finished(success)

var teclas_posibles = []
var tecla_actual = ""
var boca_abierta = false
var TextoInstruccion_pos_original = Vector2.ZERO
var puede_presionar := false


func _ready():
	# Generar teclas posibles: letras, números y especiales
	var teclas_especiales = ["SPACE"]

	for i in range(65, 91):
		teclas_posibles.append(String.chr(i))  # Letras A–Z

	for i in range(48, 58):
		teclas_posibles.append(String.chr(i))  # Números 0–9

	for nombre in teclas_especiales:
		teclas_posibles.append(nombre)

	# Ocultar todos los elementos al inicio
	$GatoAbierto.visible = false
	$GatoTriste.visible = false
	$Pulgar.visible = false
	$TextoTecla.visible = false
	$TextoInstruccion.visible = false
	$ManoAbierta.visible = false
	$PescadoSuelto.visible = false
	$BarraTiempo.visible = false

	# Empezar microjuego altiro
	_on_timer_apertura_timeout()



func _input(event):
	if not puede_presionar or not boca_abierta:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return  # Ignora ESC

		var tecla_presionada = event.as_text()
		if tecla_presionada == tecla_actual:
			acierto()
		else:
			fallo()


func acierto():
	puede_presionar = false
	$MusicaMicrojuego.stop()
	boca_abierta = false
	$TextoTecla.visible = false
	$GatoAbierto.visible = false
	$GatoCerrado.visible = true
	$BarraTiempo.visible = false
	$TimerBarra.stop()

	$ManoConPescado.visible = false
	$ManoAbierta.visible = true

	$PescadoSuelto.visible = true
	$PescadoSuelto.position = $ManoAbierta.position

	var destino = $PescadoSuelto.position + Vector2(0, 250)
	var tween = create_tween()
	tween.tween_property($PescadoSuelto, "position", destino, 0.35)
	await tween.finished

	$PescadoSuelto.visible = false
	$ManoAbierta.visible = false
	$Pulgar.visible = true

	emit_signal("finished", true)

func fallo():
	puede_presionar = false
	$MusicaMicrojuego.stop()
	boca_abierta = false
	$TextoTecla.visible = false
	$GatoAbierto.visible = false
	$GatoCerrado.visible = true
	$BarraTiempo.visible = false
	$TimerBarra.stop()

	$ManoConPescado.visible = false
	$ManoAbierta.visible = true

	$PescadoSuelto.visible = true
	$PescadoSuelto.position = $ManoAbierta.position

	var posicion_1 = $PescadoSuelto.position + Vector2(0, 250)
	var tween1 = create_tween()
	tween1.tween_property($PescadoSuelto, "position", posicion_1, 0.12)
	await tween1.finished

	var posicion_2 = posicion_1 + Vector2(150, 40)
	var tween2 = create_tween()
	tween2.tween_property($PescadoSuelto, "position", posicion_2, 0.1)
	await tween2.finished

	var posicion_3 = posicion_2 + Vector2(60, 200)
	var tween3 = create_tween()
	tween3.tween_property($PescadoSuelto, "position", posicion_3, 0.15)
	await tween3.finished

	$PescadoSuelto.visible = false
	$ManoAbierta.visible = false
	$GatoCerrado.visible = false
	$GatoTriste.visible = true
	if $MusicaMicrojuego.playing:
		$MusicaMicrojuego.stop()
		await get_tree().create_timer(0.05).timeout  # pausa mínima para asegurar que se detuvo
	emit_signal("finished", false)

	

func _on_timer_apertura_timeout() -> void:
	boca_abierta = true
	tecla_actual = teclas_posibles[randi() % teclas_posibles.size()]
	puede_presionar = true

	# Mostrar "¡Apreta!" y reproducir voz
	$TextoInstruccion.text = "¡Aprieta!"
	$TextoInstruccion.visible = true
	$AudioAprieta.play()

	await get_tree().create_timer(1.0).timeout

	# Ocultar instrucción y mostrar el juego
	$TextoInstruccion.visible = false
	$TextoTecla.text = tecla_actual
	$TextoTecla.visible = true
	$GatoCerrado.visible = false
	$GatoAbierto.visible = true

	$BarraTiempo.max_value = 1.5
	$BarraTiempo.value = 1.5
	$BarraTiempo.visible = true

	$TimerBarra.wait_time = 1.5
	$TimerBarra.start()

	$TimerCierre.wait_time = 1.5
	$TimerCierre.start()

	$MusicaMicrojuego.play()

func _on_timer_cierre_timeout() -> void:
	if boca_abierta:
		fallo()

func _on_timer_barra_timeout() -> void:
	if boca_abierta:
		fallo()

func _process(delta):
	# Actualizar barra de tiempo
	if $TimerBarra.time_left > 0:
		$BarraTiempo.value = $TimerBarra.time_left

		var porcentaje = $TimerBarra.time_left / $TimerBarra.wait_time
		if porcentaje > 0.5:
			$BarraTiempo.add_theme_color_override("fg_color", Color(0, 1, 0))  # Verde
		elif porcentaje > 0.2:
			$BarraTiempo.add_theme_color_override("fg_color", Color(1, 1, 0))  # Amarillo
		else:
			$BarraTiempo.add_theme_color_override("fg_color", Color(1, 0, 0))  # Rojo

	# Temblor de "¡Aprieta!"
	if $TextoInstruccion.visible:
		var shake = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		$TextoInstruccion.position = TextoInstruccion_pos_original + shake
	else:
		$TextoInstruccion.position = TextoInstruccion_pos_original
func _exit_tree():
	if is_instance_valid($MusicaMicrojuego) and $MusicaMicrojuego.playing:
		$MusicaMicrojuego.stop()
