extends Node2D
signal finished(success)

@onready var crosshair = $Crosshair
@onready var target = $Target
@onready var timer = $TiempoRestante
@onready var label = $Instruccion
@onready var label_controles = $TextoControles
@onready var time_bar = $barraDeTiempo

# Variables de dificultad
var nivel_dificultad = 1
var crosshair_speed = 800
var target_speed = 500
var hit_distance = 190  # Fijo, no se modifica
var duracion_juego = 3.0
var disparos_permitidos = 1

var screen_size
var direction = Vector2(1, 0)
var jugando = true
var disparos_realizados = 0
var juego_terminado = false  # 🔧 NUEVA VARIABLE para controlar estado

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			duracion_juego = 3.0
			crosshair_speed = 800
			target_speed = 1000
			hit_distance = 190
			disparos_permitidos = 1
		2:
			duracion_juego = 2.5
			crosshair_speed = 750
			target_speed = 1500
			hit_distance = 190
			disparos_permitidos = 1
		3:
			duracion_juego = 2.0
			crosshair_speed = 700
			target_speed = 2000
			hit_distance = 190
			disparos_permitidos = 1
		4:
			duracion_juego = 1.8
			crosshair_speed = 650
			target_speed = 3000
			hit_distance = 190
			disparos_permitidos = 1
		5:
			duracion_juego = 1.5
			crosshair_speed = 600
			target_speed = 4000
			hit_distance = 190
			disparos_permitidos = 1
		6:
			duracion_juego = 1.3
			crosshair_speed = 550
			target_speed = 5000
			hit_distance = 190
			disparos_permitidos = 1
		7:
			duracion_juego = 1.0
			crosshair_speed = 500
			target_speed = 5500
			hit_distance = 190
			disparos_permitidos = 1
		8:
			duracion_juego = 0.8
			crosshair_speed = 450
			target_speed = 6000
			hit_distance = 190
			disparos_permitidos = 1

	print("Nivel configurado:", nivel_dificultad)
	print("Duración:", duracion_juego)
	print("Velocidad mira:", crosshair_speed)
	print("Velocidad objetivo:", target_speed)
	print("Distancia acierto:", hit_distance)
	print("Disparos permitidos:", disparos_permitidos)

func _ready():
	randomize()
	disparos_realizados = 0
	juego_terminado = false  # 🔧 INICIALIZAR estado
	
	screen_size = get_viewport_rect().size
	reset_crosshair()
	reset_target()

	# Configurar barra de tiempo y timer INMEDIATAMENTE
	time_bar.max_value = duracion_juego
	time_bar.value = duracion_juego
	time_bar.visible = true

	# Conectar y arrancar timer AL MISMO TIEMPO
	timer.timeout.connect(_on_timer_timeout)
	timer.start(duracion_juego)

	# Mostrar instrucciones SIN parar el timer
	label.visible = true
	label_controles.visible = true

	# Ocultar instrucción después de 1 segundo, pero timer sigue corriendo
	await get_tree().create_timer(1.0).timeout
	# 🔧 CAMBIO: Solo ocultar si el juego NO ha terminado
	if not juego_terminado:
		label.visible = false

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		return  # Ignora ESC

	if not jugando:
		return

	move_crosshair(delta)
	move_target(delta)

	# Actualizar barra de tiempo
	if timer.time_left >= 0:
		time_bar.value = timer.time_left

	# Disparo con SPACE o Enter
	if (Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE)) and jugando:
		check_hit()

func move_crosshair(delta):
	var dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	crosshair.position += dir.normalized() * crosshair_speed * delta
	crosshair.position.x = clamp(crosshair.position.x, 0, screen_size.x)
	crosshair.position.y = clamp(crosshair.position.y, 0, screen_size.y)

func move_target(delta):
	target.position += direction * target_speed * delta
	if target.position.x < 0 or target.position.x > screen_size.x:
		direction.x *= -1

func check_hit():
	if not jugando:
		return
	
	disparos_realizados += 1
	var distance = crosshair.position.distance_to(target.position)
	
	if distance < hit_distance:
		# VICTORIA - Le diste al blanco
		terminar_juego_con_victoria()
	else:
		# Verificar si agotó los disparos
		if disparos_realizados >= disparos_permitidos:
			# DERROTA - Fallaste el disparo
			terminar_juego_con_derrota("¡Fallaste!")

func terminar_juego_con_victoria():
	print("¡Victoria! Le diste al blanco")
	
	# 🔧 MARCAR como terminado INMEDIATAMENTE
	juego_terminado = true
	jugando = false
	timer.stop()
	
	# Ocultar elementos de juego
	time_bar.visible = false
	target.visible = false
	label_controles.visible = false
	crosshair.visible = false
	
	# 🔧 MOSTRAR mensaje y FORZAR que permanezca visible
	label.text = "¡Lo atrapaste!"
	label.visible = true
	
	# 🔧 ASEGURAR que el mensaje se mantiene visible
	await get_tree().create_timer(0.5).timeout
	
	# 🔧 VERIFICAR NUEVAMENTE que el mensaje sigue visible
	label.text = "¡Lo atrapaste!"
	label.visible = true
	
	emit_signal("finished", true)

func terminar_juego_con_derrota(mensaje: String):
	print("Derrota: " + mensaje)
	
	# 🔧 MARCAR como terminado INMEDIATAMENTE
	juego_terminado = true
	jugando = false
	timer.stop()
	
	# Ocultar elementos de juego
	time_bar.visible = false
	target.visible = false
	label_controles.visible = false
	crosshair.visible = false
	
	# 🔧 MOSTRAR mensaje y FORZAR que permanezca visible
	label.text = mensaje
	label.visible = true
	
	# 🔧 ASEGURAR que el mensaje se mantiene visible
	await get_tree().create_timer(0.5).timeout
	
	# 🔧 VERIFICAR NUEVAMENTE que el mensaje sigue visible
	label.text = mensaje
	label.visible = true
	
	emit_signal("finished", false)

func _on_timer_timeout():
	if not jugando:
		return
	
	terminar_juego_con_derrota("¡Tiempo agotado!")

func reset_crosshair():
	crosshair.position = screen_size / 2

func reset_target():
	target.position = Vector2(100, 200)

# 🔧 FUNCIÓN DE SEGURIDAD: Mantener mensaje visible por la fuerza
func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		print("Microjuego cerrándose...")
	elif what == NOTIFICATION_VISIBILITY_CHANGED:
		if juego_terminado and label:
			# Forzar que el mensaje se mantenga visible
			label.visible = true
