extends Control

func _ready():
	# Mostrar número de microjuego
	var label_micro = $ContenedorInfo/LabelMicrojuego
	if label_micro:
		label_micro.text = "Microjuego " + str(Juego.microjuego_actual + 1)
	else:
		print("❌ NO se encontró el nodo LabelMicrojuego")

	# Mostrar vidas con corazones
	var label_vidas = $ContenedorInfo/LabelVidas
	if label_vidas:
		var corazones = ""
		for i in range(Juego.vidas):
			corazones += "❤"
		label_vidas.text = "Vidas: " + corazones
	else:
		print("❌ NO se encontró el nodo LabelVidas")

	# Iniciar cuenta regresiva
	$TimerTransicion.start(2.0)

func _on_TimerTransicion_timeout():
	# Verificar fin del juego
	if Juego.vidas <= 0:
		get_tree().change_scene_to_file("res://escenas/fin_derrota.tscn")
		return

	if Juego.microjuego_actual >= Juego.max_microjuegos:
		get_tree().change_scene_to_file("res://escenas/fin_victoria.tscn")
		return

	# Aumentar el contador de microjuegos jugados
	Juego.microjuego_actual += 1

	# Cargar un microjuego al azar
	var escena_controlador = load("res://escenas/controlador_microjuego.tscn").instantiate()
	escena_controlador.escena_microjuego = load(Juego.obtener_microjuego_aleatorio())
	get_tree().root.add_child(escena_controlador)
	get_tree().current_scene.queue_free()
