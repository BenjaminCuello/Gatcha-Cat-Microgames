extends Node2D
signal finished(success)

@onready var crosshair = $Crosshair
@onready var target = $Target
@onready var timer = $TiempoRestante
@onready var label = $Instruccion
@onready var label_controles = $TextoControles
@onready var time_bar = $barraDeTiempo

var crosshair_speed = 1000
var target_speed = 500
var screen_size
var direction = Vector2(1, 0)
var jugando = true
@export var duracion_juego = 5.0

func _ready():
	randomize()
	duracion_juego = [3.0, 4.0, 5.0].pick_random()
	
	screen_size = get_viewport_rect().size
	reset_crosshair()
	reset_target()

	await get_tree().create_timer(1.0).timeout
	
	label.visible = true
	label_controles.visible = true  # Asume que el texto ya está configurado en el editor

	# Configurar barra de tiempo
	time_bar.max_value = duracion_juego
	time_bar.value = duracion_juego

	# Conectar la señal del timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start(duracion_juego)

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
		
	var distance = crosshair.position.distance_to(target.position)
	if distance < 190:
		# VICTORIA - Le diste al blanco
		jugando = false
		timer.stop()
		target.visible = false
		label_controles.visible = false  # Ocultar controles
		label.text = "¡Lo atrapaste!"
		label.visible = true
		print("¡Victoria! Le diste al blanco")
		emit_signal("finished", true)
	else:
		# DERROTA - Fallaste el disparo
		jugando = false
		timer.stop()
		target.visible = false
		label_controles.visible = false  # Ocultar controles
		label.text = "¡Fallaste!"
		label.visible = true
		print("Fallaste el disparo")
		emit_signal("finished", false)

func _on_timer_timeout():
	if not jugando:
		return
	jugando = false
	label_controles.visible = false  # Ocultar controles
	label.text = "¡Tiempo agotado!"
	label.visible = true
	emit_signal("finished", false)
	print("juego terminado por tiempo, perdiste")

func reset_crosshair():
	crosshair.position = screen_size / 2

func reset_target():
	target.position = Vector2(100, 200)
