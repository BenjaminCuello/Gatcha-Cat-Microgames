extends Node2D
signal finished(success)

@onready var player = $Player
@onready var good_food = $GoodFood
@onready var bad_food = $BadFood
@onready var label = $Instruccion  # Label para mensaje principal
@onready var label_controles = $TextoControles  # Label para controles

# Variables de dificultad
var nivel_dificultad = 1
var screen_size
var base_fall_speed = 500
var fall_speed
var food_limit_y = 1000
var jugando = true
var fall_count = 0
var max_falls = 2
var player_speed = 1000
var separacion_minima = 150
var juego_terminado = false
var comidas_atrapadas = 0

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			base_fall_speed = 500
			player_speed = 1000
			max_falls = 2
			separacion_minima = 150
		2:
			base_fall_speed = 600
			player_speed = 950
			max_falls = 3
			separacion_minima = 130
		3:
			base_fall_speed = 700
			player_speed = 900
			max_falls = 3
			separacion_minima = 110
		4:
			base_fall_speed = 800
			player_speed = 850
			max_falls = 4
			separacion_minima = 100
		5:
			base_fall_speed = 900
			player_speed = 800
			max_falls = 4
			separacion_minima = 90
		6:
			base_fall_speed = 1000
			player_speed = 750
			max_falls = 5
			separacion_minima = 80
		7:
			base_fall_speed = 1100
			player_speed = 700
			max_falls = 5
			separacion_minima = 70
		8:
			base_fall_speed = 1200
			player_speed = 650
			max_falls = 6
			separacion_minima = 60

	print("Nivel configurado:", nivel_dificultad)
	print("Velocidad caída:", base_fall_speed)
	print("Velocidad jugador:", player_speed)
	print("Comidas requeridas:", max_falls)
	print("Separación mínima:", separacion_minima)

func _ready():
	randomize()
	fall_count = 0
	comidas_atrapadas = 0
	juego_terminado = false
	screen_size = get_viewport_rect().size

	# Configurar velocidad inicial
	fall_speed = base_fall_speed

	# 🔧 CORREGIDO: Configurar instrucciones como estaban originalmente
	label.text = "¡Come bien!"
	label.visible = true
	label_controles.text = "Usa ← → para moverte."
	label_controles.visible = true

	# Conectar señales de colisión
	good_food.connect("body_entered", Callable(self, "_on_good_food_body_entered"))
	bad_food.connect("body_entered", Callable(self, "_on_bad_food_body_entered"))

	launch_food()

func _process(delta):
	if not jugando:
		return

	handle_player_input(delta)
	move_foods(delta)

	# 🔧 CORREGIDO: NO actualizar texto durante el juego, mantenerlo como estaba

func handle_player_input(delta):
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	player.position.x += dir * player_speed * delta
	player.position.x = clamp(player.position.x, 0, screen_size.x)

func move_foods(delta):
	if !good_food.visible:
		return

	# Mover comida
	good_food.position.y += fall_speed * delta
	bad_food.position.y += fall_speed * delta

	# CONDICIÓN DE DERROTA: Comida buena se cae al suelo
	if good_food.position.y > food_limit_y:
		end_game(false, "¡Derrota!")

	# Si la basura cae sola, simplemente desaparece
	if bad_food.position.y > food_limit_y:
		bad_food.visible = false

func launch_food():
	# Lanzar comida hasta que se complete el objetivo
	if fall_count >= max_falls:
		end_game(true, "¡Victoria!")
		return

	var view_width = screen_size.x
	var margin = 100
	var good_x = randf_range(margin, view_width - margin)
	var bad_x = randf_range(margin, view_width - margin)

	# Asegurar separación mínima según dificultad
	while abs(good_x - bad_x) < separacion_minima:
		bad_x = randf_range(margin, view_width - margin)

	var spawn_y = -50
	good_food.position = Vector2(good_x, spawn_y)
	bad_food.position = Vector2(bad_x, spawn_y)

	good_food.visible = true
	bad_food.visible = true

	fall_count += 1
	print("Comida lanzada - Fall count:", fall_count, "- Comidas atrapadas:", comidas_atrapadas)

func _on_good_food_body_entered(body):
	if body == player and jugando:
		good_food.visible = false
		bad_food.visible = false
		
		# Incrementar contador de éxitos
		comidas_atrapadas += 1
		print("¡Comida atrapada! Progreso:", comidas_atrapadas, "/", max_falls)
		
		# Verificar condición de victoria
		if comidas_atrapadas >= max_falls:
			end_game(true, "¡Victoria!")
			return
		
		await get_tree().create_timer(0.5).timeout
		
		# Lanzar siguiente comida
		launch_food()

func _on_bad_food_body_entered(body):
	if body == player and jugando:
		# CONDICIÓN DE DERROTA: Comiste comida mala
		end_game(false, "Comiste basura")

func end_game(success, message):
	if not jugando:
		return
	
	# Marcar como terminado INMEDIATAMENTE
	juego_terminado = true
	jugando = false
	
	# 🔧 CORREGIDO: Ocultar elementos como estaba originalmente
	label.text = message
	label.visible = true
	label_controles.visible = false  # Ocultar controles
	good_food.visible = false
	bad_food.visible = false
	
	print("Juego terminado:", message, "- Éxito:", success)
	print("Comidas atrapadas finales:", comidas_atrapadas, "/", max_falls)
	
	# Asegurar que el mensaje se mantiene visible
	await get_tree().create_timer(1.5).timeout
	
	# Verificar nuevamente que el mensaje sigue visible
	label.text = message
	label.visible = true
	
	emit_signal("finished", success)
