extends Control

@export var microjuego_actual: int = 1
@export var total_microjuegos: int = 999  # opcional, si quieres mostrarlo como 1/∞

@onready var label_vidas := $ContenedorInfo/LabelVidas
@onready var label_micro := $ContenedorInfo/LabelMicrojuego

func _ready():
	$MusicaInicio.play()

	mostrar_info()
	mostrar_vidas()

	$TimerTransicion.start(2.0)

func mostrar_info():
	if label_micro:
		label_micro.text = "Microjuego " + str(microjuego_actual)
	else:
		print("❌ LabelMicrojuego no encontrado")

func mostrar_vidas():
	if label_vidas:
		var corazones := ""
		var multiplayer_logic := get_node_or_null("/root/MultiplayerScene/game_logic")
		if multiplayer_logic:
			for i in range(multiplayer_logic.vidas):
				corazones += "❤"
			label_vidas.text = "Vidas: " + corazones
		else:
			label_vidas.text = "Vidas: ❤❤❤"
			print("⚠️ No se encontró game_logic en MultiplayerScene")
	else:
		print("❌ LabelVidas no encontrado")

func _on_TimerTransicion_timeout():
	# Llamar a MultiplayerScene para continuar
	var escena_mp := get_node_or_null("/root/MultiplayerScene")
	if escena_mp and escena_mp.has_method("_iniciar_microjuego"):
		escena_mp._iniciar_microjuego()
		queue_free()
	else:
		print("❌ No se encontró MultiplayerScene o método _iniciar_microjuego")
