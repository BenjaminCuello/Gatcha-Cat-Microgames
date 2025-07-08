extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado


# Variables de dificultad
var nivel_dificultad = 1
var tiempo_total_juego = 6.0  # 🔧 Tiempo total para completar todas las teclas
var cantidad_teclas = 6      # 🔧 Cantidad de teclas a presionar

var flechas = [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
var flechas_texto = {"↑": KEY_UP, "↓": KEY_DOWN, "←": KEY_LEFT, "→": KEY_RIGHT}
var flechas_mostradas = []
var index_actual := 0
var esperando_input := false

@onready var texto = $TextoInstruccion
@onready var controles = $TextoControles
@onready var gato = $GatoSurfeando
@onready var olas = $Olas
@onready var timer_olas = $TimerOlas

var textura_ola1 : Texture2D
var textura_ola2 : Texture2D
var usando_ola1 := true

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			cantidad_teclas = 4
			tiempo_total_juego = 5.0  # 1.25s por tecla
		2:
			cantidad_teclas = 5
			tiempo_total_juego = 5.0  # 1.0s por tecla
		3:
			cantidad_teclas = 6
			tiempo_total_juego = 5.0  # 0.83s por tecla
		4:
			cantidad_teclas = 6
			tiempo_total_juego = 4.5  # 0.75s por tecla
		5:
			cantidad_teclas = 7
			tiempo_total_juego = 4.5  # 0.64s por tecla
		6:
			cantidad_teclas = 8
			tiempo_total_juego = 4.5  # 0.56s por tecla
		7:
			cantidad_teclas = 8
			tiempo_total_juego = 4.0  # 0.5s por tecla
		8:
			cantidad_teclas = 10
			tiempo_total_juego = 4.0  # 0.4s por tecla

	print("Nivel configurado:", nivel_dificultad)
	print("Cantidad de teclas:", cantidad_teclas)
	print("Tiempo total:", tiempo_total_juego, "segundos")
	print("Tiempo promedio por tecla:", "%.2f" % (tiempo_total_juego / cantidad_teclas), "segundos")

func _ready():
	gato.visible = true
	texto.text = "¡Prepárate!"
	texto.visible = true
	controles.visible = false

	# Carga las texturas
	textura_ola1 = load("res://Microjuegos/Branco/8_Surfeando/Sprites/ola1.png")
	textura_ola2 = load("res://Microjuegos/Branco/8_Surfeando/Sprites/ola2.png")

	# Establece la textura inicial
	olas.texture = textura_ola1

	# Conecta el timer si no lo hiciste desde el editor
	timer_olas.timeout.connect(_on_TimerOlas_timeout)
	
	# 🔧 NUEVO: Configurar barra de tiempo según dificultad
	$BarraTiempo.max_value = tiempo_total_juego
	$BarraTiempo.value = tiempo_total_juego
	$BarraTiempo.visible = true
	
	# 🔧 NUEVO: El timer de barra usa el tiempo total configurado
	$TimerBarra.wait_time = tiempo_total_juego
	$TimerBarra.start()

	await get_tree().create_timer(1.0).timeout
	texto.visible = false
	$TimerApertura.start()

	# Generar flechas sin repeticiones consecutivas
	generar_flechas_sin_repeticiones()

# Función para generar flechas evitando repeticiones consecutivas
func generar_flechas_sin_repeticiones():
	flechas_mostradas.clear()
	
	# 🔧 NUEVO: Usar cantidad_teclas variable
	for i in range(cantidad_teclas):
		var flecha_elegida
		
		if i == 0:
			# Primera flecha puede ser cualquiera
			flecha_elegida = flechas[randi() % flechas.size()]
		else:
			# Para el resto, evitar repetir la anterior
			var flecha_anterior = flechas_mostradas[i - 1]
			var flechas_disponibles = []
			
			# Crear lista de flechas disponibles (sin la anterior)
			for flecha in flechas:
				if flecha != flecha_anterior:
					flechas_disponibles.append(flecha)
			
			# Elegir una de las disponibles
			flecha_elegida = flechas_disponibles[randi() % flechas_disponibles.size()]
		
		flechas_mostradas.append(flecha_elegida)
	
	# Debug: mostrar la secuencia generada
	var secuencia_debug = []
	for flecha in flechas_mostradas:
		for simbolo in flechas_texto.keys():
			if flechas_texto[simbolo] == flecha:
				secuencia_debug.append(simbolo)
				break
	
	print("Secuencia generada (", cantidad_teclas, " teclas):", " → ".join(secuencia_debug))

func _on_TimerApertura_timeout():
	mostrar_flecha()

func mostrar_flecha():
	if index_actual >= flechas_mostradas.size():
		victoria()
		return

	esperando_input = true
	var keycode = flechas_mostradas[index_actual]

	var simbolo = ""
	for s in flechas_texto.keys():
		if flechas_texto[s] == keycode:
			simbolo = s
			break

	# 🔧 NUEVO: Mostrar progreso y tiempo restante
	var tiempo_restante = $TimerBarra.time_left
	controles.text = "Presiona: " + simbolo + "\n(%d/%d) - %.1fs" % [index_actual + 1, cantidad_teclas, tiempo_restante]
	controles.visible = true

	# 🔧 CAMBIO: Ya no usamos TimerRespuesta individual
	# El único límite es el tiempo total del juego
	print("Flecha", index_actual + 1, "/", cantidad_teclas, ":", simbolo, "- Tiempo total restante:", "%.1f" % tiempo_restante, "s")

func _input(event):
	if not esperando_input:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return

		var keycode_presionado = event.keycode
		var esperado = flechas_mostradas[index_actual]

		if keycode_presionado == esperado:
			acierto()
		else:
			derrota()

func acierto():
	esperando_input = false
	controles.visible = false

	index_actual += 1
	
	# 🔧 NUEVO: Pequeña pausa entre teclas para que se vea el progreso
	await get_tree().create_timer(0.1).timeout
	mostrar_flecha()

func derrota():
	if esperando_input:
		esperando_input = false
		$TimerBarra.stop()

		texto.text = "¡Fallaste!"
		texto.visible = true
		controles.visible = false

		await get_tree().create_timer(1.0).timeout
		emit_signal("microjuego_fallado")  # NUEVO
		emit_signal("finished", false)


func victoria():
	$TimerBarra.stop()
	texto.text = "¡Genial! Completaste %d teclas!" % cantidad_teclas
	texto.visible = true
	controles.visible = false
	await get_tree().create_timer(1.2).timeout
	emit_signal("microjuego_superado")  # NUEVO
	emit_signal("finished", true)


# 🔧 ELIMINADO: Ya no usamos _on_TimerRespuesta_timeout() individual

func _on_TimerBarra_timeout():
	derrota()
	
func _on_TimerOlas_timeout():
	if usando_ola1:
		olas.texture = textura_ola2
	else:
		olas.texture = textura_ola1
	usando_ola1 = !usando_ola1

func _process(delta):
	if $TimerBarra.time_left > 0:
		$BarraTiempo.value = $TimerBarra.time_left
