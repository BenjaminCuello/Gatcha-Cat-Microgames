extends Node2D

signal microjuego_superado
signal microjuego_fallado
signal finished(success)

var duracion_juego := 8.0
var juego_activo := true

func _ready():
	juego_activo = true
	$GatitoVolador.finished.connect(_on_GatitoVolador_finished)

	$LabelInstruccion.text = "¡Presiona espacio para volar!"
	$LabelInstruccion.visible = true

	$BarraTiempo.max_value = duracion_juego
	$BarraTiempo.value = duracion_juego
	$BarraTiempo.visible = true

	$TimerJuego.wait_time = duracion_juego
	$TimerJuego.start()

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
		$LabelInstruccion.text = "¡Ganaste! Sobreviviste al tiempo."
		emit_signal("microjuego_superado")

	else:
		$LabelInstruccion.text = "¡Perdiste! Tocaste una tubería."
		emit_signal("microjuego_fallado")


	$LabelInstruccion.visible = true

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", success)
