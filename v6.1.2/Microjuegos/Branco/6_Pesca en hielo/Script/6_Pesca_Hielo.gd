extends Node2D
signal finished(success)

@onready var pez = $Pez
@onready var hilo = $Hilo
@onready var caña = $Pescar
@onready var texto_instruccion = $TextoInstruccion
@onready var texto_controles = $TextoControles
@onready var barra_tiempo = $BarraTiempo
@onready var timer_barra = $TimerBarra

var obstaculos = []
var terminado = false
var puede_mover = true
var invulnerable = false
var velocidad = 250
var limite_superior = 200
var limite_inferior = 950

# Variables para la dificultad
var nivel_dificultad = 1
var tiempo_juego = 8.0

# Función para configurar la dificultad (llamada desde el sistema principal)
func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

# Función para ajustar los parámetros según el nivel
func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:  # Nivel 1 - Fácil
			tiempo_juego = 6.0
			velocidad = 210  # Más lento, más control
		2:  # Nivel 2
			tiempo_juego = 5.0
			velocidad = 260  # Aumentado como pediste
		3:  # Nivel 3
			tiempo_juego = 4.0
			velocidad = 320
		4:  # Nivel 4
			tiempo_juego = 3.0
			velocidad = 370
		5:  # Nivel 5
			tiempo_juego = 2.5
			velocidad = 420
		6:  # Nivel 6
			tiempo_juego = 2.0
			velocidad = 490
		7:  # Nivel 7
			tiempo_juego = 1.8
			velocidad = 540
		8:  # Nivel 8 - Máximo
			tiempo_juego = 1.5
			velocidad = 600  # Súper rápido, muy difícil de controlar

	print("=== DIFICULTAD CONFIGURADA ===")
	print("Nivel: ", nivel_dificultad)
	print("Tiempo: ", tiempo_juego, " segundos")
	print("Velocidad del pez: ", velocidad)
	print("===============================")

func _ready():
	# Configurar dificultad por defecto (será sobrescrita por el sistema principal)
	ajustar_parametros_dificultad()
	
	obstaculos = get_tree().get_nodes_in_group("Obstaculo")
	iniciar_juego()

func iniciar_juego():
	terminado = false
	puede_mover = true
	invulnerable = false
	pez.position.y = limite_inferior

	texto_instruccion.text = "¡Sube al pez sin chocar!"
	texto_controles.text = "Usa ↑ ↓ para mover"
	texto_instruccion.visible = true
	texto_controles.visible = true

	# Usar el tiempo configurado por la dificultad
	barra_tiempo.max_value = tiempo_juego
	barra_tiempo.value = barra_tiempo.max_value
	barra_tiempo.visible = true
	timer_barra.start(tiempo_juego)

	if pez.area_entered.is_connected(_on_pez_area_entered):
		pez.area_entered.disconnect(_on_pez_area_entered)
	pez.area_entered.connect(_on_pez_area_entered)

	for caja in obstaculos:
		if caja.has_node("CollisionShape2D"):
			caja.get_node("CollisionShape2D").disabled = false
		caja.set_process(true)

func _process(delta):
	if terminado or timer_barra.is_stopped() or not puede_mover:
		return

	var input_y = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	# Usar la velocidad configurada por la dificultad
	pez.position.y += -input_y * velocidad * delta
	pez.position.y = clamp(pez.position.y, limite_superior, limite_inferior)

	var offset_caña = Vector2(-200, -30)
	hilo.clear_points()
	hilo.add_point(hilo.to_local(caña.global_position + offset_caña))
	hilo.add_point(hilo.to_local(pez.global_position))

	if pez.position.y <= limite_superior:
		for caja in obstaculos:
			caja.set_process(false)
		finalizar_juego(true, "¡Pez atrapado!")

	barra_tiempo.value = timer_barra.time_left

func _on_pez_area_entered(area):
	if terminado or invulnerable:
		return

	if area.is_in_group("Obstaculo"):
		invulnerable = true
		puede_mover = false
		for caja in obstaculos:
			caja.set_process(false)
		finalizar_juego(false, "¡Chocaste con un obstáculo!")

func _on_TimerBarra_timeout():
	if terminado:
		return
	finalizar_juego(false, "¡Se acabó el tiempo!")

func finalizar_juego(exito: bool, mensaje: String):
	terminado = true
	puede_mover = false
	timer_barra.stop()
	barra_tiempo.visible = false
	texto_controles.visible = false
	texto_instruccion.text = mensaje
	texto_instruccion.visible = true

	for caja in obstaculos:
		if caja.has_node("CollisionShape2D"):
			caja.get_node("CollisionShape2D").disabled = true
		caja.set_process(false)

	if pez.area_entered.is_connected(_on_pez_area_entered):
		pez.area_entered.disconnect(_on_pez_area_entered)

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", exito)
