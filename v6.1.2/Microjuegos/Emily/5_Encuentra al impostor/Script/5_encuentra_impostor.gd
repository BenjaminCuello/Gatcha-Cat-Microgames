extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado


@onready var animales = [$Gato, $Mapache, $Zarigueya]
@onready var flecha = $Flecha
@onready var texto_instruccion = $TextoInstruccion
@onready var texto_controles = $TextoControles
@onready var timer_barra = $TimerBarra
@onready var barra_tiempo = $BarraTiempo

# Variables de dificultad
var nivel_dificultad = 1
var duracion_juego = 3.0  # 🔧 CAMBIADO: Nivel 1 = 3 segundos

var ancho_pantalla = ProjectSettings.get_setting("display/window/size/viewport_width")
var y_base = 700
var espacio = 500

var posiciones = [
	Vector2(ancho_pantalla / 2 - espacio, y_base),
	Vector2(ancho_pantalla / 2, y_base - 100),  # El del medio más arriba
	Vector2(ancho_pantalla / 2 + espacio, y_base)
]

var orden_animales = []
var indice_correcto: int = 0
var indice_flecha: int = 0
var terminado = false
var juego_terminado = false

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			duracion_juego = 3.0
		2:
			duracion_juego = 2.5
		3:
			duracion_juego = 2.0
		4:
			duracion_juego = 1.8
		5:
			duracion_juego = 1.6
		6:
			duracion_juego = 1.4
		7:
			duracion_juego = 1.2
		8:
			duracion_juego = 1.0

	print("Nivel configurado:", nivel_dificultad)
	print("Duración:", duracion_juego)

func _ready():
	terminado = false
	juego_terminado = false
	randomize()
	iniciar_juego()

func iniciar_juego():
	texto_instruccion.text = "Encuentra al gato"
	texto_controles.text = "Usa ← → para mover. Espacio para elegir."
	texto_instruccion.visible = true
	texto_controles.visible = true

	# Mezclar los animales
	orden_animales = animales.duplicate()
	orden_animales.shuffle()

	for i in range(orden_animales.size()):
		orden_animales[i].global_position = posiciones[i]
		orden_animales[i].visible = true
		if orden_animales[i].name == "Gato":
			indice_correcto = i

	# Posicionar flecha
	indice_flecha = 0
	_update_flecha_pos()

	# 🔧 SOLO MODIFICADO: Barra de tiempo con duración según dificultad
	barra_tiempo.max_value = duracion_juego
	barra_tiempo.value = barra_tiempo.max_value
	barra_tiempo.visible = true

	# 🔧 SOLO MODIFICADO: Timer con duración según dificultad
	timer_barra.timeout.connect(_on_timer_barra_timeout)
	timer_barra.start(duracion_juego)

func _input(event):
	if terminado:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				indice_flecha = (indice_flecha - 1 + 3) % 3
				_update_flecha_pos()
			KEY_RIGHT:
				indice_flecha = (indice_flecha + 1) % 3
				_update_flecha_pos()
			KEY_SPACE:
				verificar_respuesta()

func _update_flecha_pos():
	var offset_y = -200
	var offset_x = -20
	if indice_flecha == 1:  # El del medio más arriba
		offset_y = -200
	flecha.global_position = posiciones[indice_flecha] + Vector2(offset_x, offset_y)

func verificar_respuesta():
	if terminado:
		return
		
	# Marcar como terminado INMEDIATAMENTE
	juego_terminado = true
	terminado = true
	timer_barra.stop()
	
	# Ocultar elementos de juego
	barra_tiempo.visible = false
	texto_controles.visible = false

	if indice_flecha == indice_correcto:
		texto_instruccion.text = "¡Correcto! Era el gato."
		texto_instruccion.visible = true
		
		# Asegurar que el mensaje se mantiene visible
		await get_tree().create_timer(1.5).timeout
		
		# Verificar nuevamente que el mensaje sigue visible
		texto_instruccion.text = "¡Correcto! Era el gato."
		texto_instruccion.visible = true
		emit_signal("microjuego_superado")

		emit_signal("finished", true)
	else:
		texto_instruccion.text = "¡Fallaste! Eso no era un gato."
		texto_instruccion.visible = true
		
		# Asegurar que el mensaje se mantiene visible
		await get_tree().create_timer(1.5).timeout
		
		# Verificar nuevamente que el mensaje sigue visible
		texto_instruccion.text = "¡Fallaste! Eso no era un gato."
		texto_instruccion.visible = true
		emit_signal("microjuego_fallado")

		emit_signal("finished", false)

func _on_timer_barra_timeout():
	if terminado:
		return
		
	# Marcar como terminado INMEDIATAMENTE
	juego_terminado = true
	terminado = true
	
	# Ocultar elementos de juego
	texto_controles.visible = false
	barra_tiempo.visible = false
	
	# Mostrar mensaje de tiempo agotado
	texto_instruccion.text = "¡Se acabó el tiempo!"
	texto_instruccion.visible = true
	
	# Asegurar que el mensaje se mantiene visible
	await get_tree().create_timer(1.5).timeout
	
	# Verificar nuevamente que el mensaje sigue visible
	texto_instruccion.text = "¡Se acabó el tiempo!"
	texto_instruccion.visible = true
	emit_signal("microjuego_fallado")

	emit_signal("finished", false)

func _process(delta):
	if not terminado and not timer_barra.is_stopped():
		barra_tiempo.value = timer_barra.time_left
