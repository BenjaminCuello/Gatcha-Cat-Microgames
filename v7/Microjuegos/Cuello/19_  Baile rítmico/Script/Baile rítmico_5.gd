extends Node2D
signal finished(success)

var teclas = []
var teclas_mostradas = []
var index_actual := 0
var esperando_input := false

# Variables de dificultad
var nivel_dificultad = 1
var tiempo_total = 6.0
var tiempo_respuesta_min = 0.8
var tiempo_respuesta_max = 1.2
var cantidad_teclas = 3

@onready var texto = $TextoInstruccion
@onready var controles = $TextoControles

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			tiempo_total = 6.0
			tiempo_respuesta_min = 0.8
			tiempo_respuesta_max = 1.2
			cantidad_teclas = 3
		2:
			tiempo_total = 5.5
			tiempo_respuesta_min = 0.7
			tiempo_respuesta_max = 1.0
			cantidad_teclas = 3
		3:
			tiempo_total = 5.0
			tiempo_respuesta_min = 0.6
			tiempo_respuesta_max = 0.9
			cantidad_teclas = 4
		4:
			tiempo_total = 4.5
			tiempo_respuesta_min = 0.5
			tiempo_respuesta_max = 0.8
			cantidad_teclas = 4
		5:
			tiempo_total = 4.0
			tiempo_respuesta_min = 0.4
			tiempo_respuesta_max = 0.7
			cantidad_teclas = 5
		6:
			tiempo_total = 3.5
			tiempo_respuesta_min = 0.3
			tiempo_respuesta_max = 0.6
			cantidad_teclas = 5
		7:
			tiempo_total = 3.0
			tiempo_respuesta_min = 0.2
			tiempo_respuesta_max = 0.5
			cantidad_teclas = 6
		8:
			tiempo_total = 2.5
			tiempo_respuesta_min = 0.1
			tiempo_respuesta_max = 0.4
			cantidad_teclas = 6

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo total:", tiempo_total)
	print("Tiempo respuesta:", tiempo_respuesta_min, "-", tiempo_respuesta_max)
	print("Cantidad teclas:", cantidad_teclas)

func _ready():
	ocultar_todos()

	$GatoQuieto.visible = true
	$Sombrero.visible = true

	texto.text = "¡Prepárate!"
	texto.visible = true
	controles.visible = false

	# Configurar barra de tiempo según dificultad
	$BarraTiempo.max_value = tiempo_total
	$BarraTiempo.value = tiempo_total
	$BarraTiempo.visible = true
	
	# Configurar timer según dificultad
	$TimerBarra.wait_time = tiempo_total
	$TimerBarra.start()

	# Esperar 1 segundo y ocultar instrucción
	await get_tree().create_timer(1.0).timeout
	texto.visible = false
	$TimerApertura.start()

	# Letras y números
	for i in range(65, 91): teclas.append(String.chr(i))
	for i in range(48, 58): teclas.append(String.chr(i))

	teclas.shuffle()
	# Seleccionar cantidad de teclas según dificultad
	teclas_mostradas = teclas.slice(0, cantidad_teclas)

func _on_TimerApertura_timeout():
	mostrar_tecla()

func mostrar_tecla():
	if index_actual >= cantidad_teclas:
		victoria()
		return

	esperando_input = true
	var tecla = teclas_mostradas[index_actual]
	controles.text = "Presiona:\n[" + tecla + "]"
	controles.visible = true

	# Tiempo de respuesta según dificultad
	var tiempo_respuesta = randf_range(tiempo_respuesta_min, tiempo_respuesta_max)
	$TimerRespuesta.start(tiempo_respuesta)

func _input(event):
	if not esperando_input:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return

		var presionada = event.as_text().to_upper()
		var esperada = teclas_mostradas[index_actual]

		if presionada == esperada:
			acierto()
		else:
			derrota()

func acierto():
	esperando_input = false
	$TimerRespuesta.stop()
	controles.visible = false

	# Cambiar poses según progreso
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
		3, 4, 5:
			# Para niveles con más teclas, mantener la última pose
			$Pose3.visible = true

	# Verificar si es la última tecla
	if index_actual == cantidad_teclas - 1:
		await get_tree().create_timer(0.5).timeout
		victoria()
		return

	index_actual += 1
	mostrar_tecla()

func derrota():
	if esperando_input:
		esperando_input = false
		$TimerRespuesta.stop()
		$TimerBarra.stop()
		$BarraTiempo.visible = false

		ocultar_poses()
		$GatoTriste.visible = true
		texto.text = "¡Fallaste!"
		texto.visible = true
		controles.visible = false

		await get_tree().create_timer(1.0).timeout
		emit_signal("finished", false)

func victoria():
	$TimerBarra.stop()
	$BarraTiempo.visible = false
	ocultar_todos()
	$GatoFeliz.visible = true
	$SombreroDinero.visible = true
	$PersonasFelices1.visible = true
	$PersonasFelices2.visible = true
	texto.text = "¡Genial!"
	texto.visible = true
	await get_tree().create_timer(1.2).timeout
	emit_signal("finished", true)

func _on_TimerRespuesta_timeout():
	derrota()

func _on_TimerBarra_timeout():
	derrota()

func _process(delta):
	if $TimerBarra.time_left > 0:
		$BarraTiempo.value = $TimerBarra.time_left

func ocultar_poses():
	$GatoQuieto.visible = false
	$Pose1.visible = false
	$Pose2.visible = false
	$Pose3.visible = false

func ocultar_todos():
	ocultar_poses()
	$GatoFeliz.visible = false
	$GatoTriste.visible = false
	$Sombrero.visible = false
	$SombreroDinero.visible = false
	$PersonasFelices1.visible = false
	$PersonasFelices2.visible = false
	texto.visible = false
	controles.visible = false
	$BarraTiempo.visible = false
