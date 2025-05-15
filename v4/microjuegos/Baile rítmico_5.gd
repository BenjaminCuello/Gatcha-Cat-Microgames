extends Node2D
signal finished(success)

var teclas = []
var teclas_mostradas = []
var index_actual := 0
var esperando_input := false

func _ready():
	ocultar_todos()
	$GatoQuieto.visible = true
	$Sombrero.visible = true
	$TextoInstruccion.text = "¡Prepárate!"
	$TextoInstruccion.visible = true

	$BarraTiempo.max_value = 6.0
	$BarraTiempo.value = 6.0
	$BarraTiempo.visible = true
	$TimerBarra.start()

	$TimerApertura.start()

	for i in range(65, 91):  # Letras A-Z
		teclas.append(String.chr(i))
	for i in range(48, 58):  # Números 0-9
		teclas.append(String.chr(i))

	teclas.shuffle()
	teclas_mostradas = teclas.slice(0, 3)

func _on_TimerApertura_timeout():
	$TextoInstruccion.visible = false
	mostrar_tecla()

func mostrar_tecla():
	if index_actual >= 3:
		victoria()
		return

	esperando_input = true
	$TextoInstruccion.text = teclas_mostradas[index_actual]
	$TextoInstruccion.visible = true
	$TimerRespuesta.start()

func _input(event):
	if not esperando_input:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return  # Ignora ESC

		var presionada = event.as_text().to_upper()
		var esperada = teclas_mostradas[index_actual]

		if presionada == esperada:
			acierto()
		else:
			derrota()


func acierto():
	esperando_input = false
	$TimerRespuesta.stop()
	$TextoInstruccion.visible = false

	match index_actual:
		0:
			$GatoQuieto.visible = false
			$Pose1.visible = true
		1:
			$Pose1.visible = false
			$Pose2.visible = true
		2:
			$Pose2.visible = false
			$Pose3.visible = true
			await get_tree().create_timer(0.5).timeout
			victoria()
			return

	index_actual += 1
	mostrar_tecla()

func derrota():
	esperando_input = false
	$TimerRespuesta.stop()
	$TimerBarra.stop()
	$TextoInstruccion.visible = false

	# Ocultar lo que esté visible (quieto o pose)
	if $GatoQuieto.visible: $GatoQuieto.visible = false
	if $Pose1.visible: $Pose1.visible = false
	if $Pose2.visible: $Pose2.visible = false
	if $Pose3.visible: $Pose3.visible = false

	$GatoTriste.visible = true
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)

func victoria():
	$TimerBarra.stop()
	ocultar_todos()
	$GatoFeliz.visible = true
	$SombreroDinero.visible = true
	$PersonasFelices1.visible = true
	$PersonasFelices2.visible = true
	await get_tree().create_timer(1.2).timeout
	emit_signal("finished", true)

func _on_TimerRespuesta_timeout():
	derrota()

func _on_TimerBarra_timeout():
	derrota()

func _process(delta):
	if $TimerBarra.time_left > 0:
		$BarraTiempo.value = $TimerBarra.time_left

func ocultar_todos():
	$GatoQuieto.visible = false
	$Sombrero.visible = false
	$Pose1.visible = false
	$Pose2.visible = false
	$Pose3.visible = false
	$GatoFeliz.visible = false
	$GatoTriste.visible = false
	$SombreroDinero.visible = false
	$PersonasFelices1.visible = false
	$PersonasFelices2.visible = false
	$TextoInstruccion.visible = false
