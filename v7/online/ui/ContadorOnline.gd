extends Control

# Script para contador online
class_name ContadorOnline

# Señales
signal vida_perdida
signal partida_terminada

# Referencias a UI
@onready var label_vidas: Label = $VBoxContainer/VidasContainer/LabelVidas
@onready var label_microjuego: Label = $VBoxContainer/MicrojuegoContainer/LabelMicrojuego
@onready var label_oponente: Label = $VBoxContainer/OponenteContainer/LabelOponente
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressContainer/ProgressBar
@onready var timer_display: Label = $VBoxContainer/TimerContainer/TimerDisplay

# Variables del juego
var vidas_jugador: int = 3
var vidas_oponente: int = 3
var microjuego_actual: String = ""
var tiempo_restante: float = 0.0
var partida_activa: bool = false

# Referencias a sistemas
var network_manager: Node
var multiplayer_game: Node

func _ready():
	print("💯 ContadorOnline iniciado")
	
	# Obtener referencias
	network_manager = get_node("/root/NetworkManager")
	multiplayer_game = get_node_or_null("../MultiplayerGame")
	
	# Conectar señales
	if network_manager:
		network_manager.game_data_received.connect(_on_game_data_received)
		network_manager.match_started.connect(_on_match_started)
		network_manager.game_ended.connect(_on_game_ended)
	
	if multiplayer_game:
		multiplayer_game.microjuego_superado.connect(_on_microjuego_superado)
		multiplayer_game.microjuego_fallado.connect(_on_microjuego_fallado)
		multiplayer_game.game_state_changed.connect(_on_game_state_changed)
	
	# Inicializar UI
	actualizar_display()

func _process(delta):
	if partida_activa and tiempo_restante > 0:
		tiempo_restante -= delta
		actualizar_timer()
		
		if tiempo_restante <= 0:
			tiempo_agotado()

func _on_match_started(data: Dictionary):
	print("🎮 Partida iniciada - Configurando contador")
	partida_activa = true
	reiniciar_contador()

func _on_game_ended(data: Dictionary):
	print("🏁 Partida terminada")
	partida_activa = false
	
	# Mostrar resultados finales
	var ganador = determinar_ganador()
	mostrar_resultado_final(ganador)

func _on_microjuego_superado():
	print("✅ Microjuego superado por jugador local")
	
	# Enviar resultado al oponente
	if network_manager:
		var data = {
			"event": "microgame_result",
			"success": true,
			"lives": vidas_jugador
		}
		network_manager.send_game_data(data)

func _on_microjuego_fallado():
	print("❌ Microjuego fallado por jugador local")
	
	# Perder una vida
	perder_vida()
	
	# Enviar resultado al oponente
	if network_manager:
		var data = {
			"event": "microgame_result",
			"success": false,
			"lives": vidas_jugador
		}
		network_manager.send_game_data(data)

func _on_game_data_received(data: Dictionary):
	var event = data.get("event", "")
	
	match event:
		"microgame_result":
			var success = data.get("success", false)
			var lives = data.get("lives", vidas_oponente)
			
			print("📊 Resultado del oponente - Éxito: ", success, " Vidas: ", lives)
			
			if not success:
				vidas_oponente = lives
			
			actualizar_display()
			
			# Verificar si alguien perdió todas las vidas
			verificar_fin_partida()

func _on_game_state_changed(state: String):
	match state:
		"PLAYING":
			iniciar_timer_microjuego()
		"RESULTS":
			detener_timer()

func perder_vida():
	if vidas_jugador > 0:
		vidas_jugador -= 1
		print("💔 Vida perdida. Vidas restantes: ", vidas_jugador)
		
		emit_signal("vida_perdida")
		actualizar_display()
		
		if vidas_jugador <= 0:
			print("💀 Se agotaron las vidas")
			partida_terminada = true
			emit_signal("partida_terminada")
			
			# Notificar fin de partida
			if network_manager:
				network_manager.finish_game({"result": "defeat", "reason": "no_lives"})

func verificar_fin_partida():
	if vidas_jugador <= 0 or vidas_oponente <= 0:
		print("🏁 Fin de partida detectado")
		
		var ganador = determinar_ganador()
		mostrar_resultado_final(ganador)
		
		# Enviar resultado final
		if network_manager:
			var result = "draw"
			if vidas_jugador > vidas_oponente:
				result = "victory"
			elif vidas_oponente > vidas_jugador:
				result = "defeat"
			
			network_manager.finish_game({"result": result, "player_lives": vidas_jugador, "opponent_lives": vidas_oponente})

func determinar_ganador() -> String:
	if vidas_jugador > vidas_oponente:
		return "player"
	elif vidas_oponente > vidas_jugador:
		return "opponent"
	else:
		return "draw"

func mostrar_resultado_final(ganador: String):
	var mensaje = ""
	match ganador:
		"player":
			mensaje = "¡Victoria! 🎉"
		"opponent":
			mensaje = "Derrota 😿"
		"draw":
			mensaje = "Empate 🤝"
	
	# Actualizar UI o cambiar escena
	print("🏆 Resultado final: ", mensaje)

func iniciar_timer_microjuego():
	tiempo_restante = 30.0  # 30 segundos por microjuego
	actualizar_timer()

func detener_timer():
	tiempo_restante = 0.0
	actualizar_timer()

func tiempo_agotado():
	print("⏰ Tiempo agotado")
	
	# Considerar como fallo
	if multiplayer_game:
		multiplayer_game.emit_signal("microjuego_fallado")

func actualizar_display():
	if label_vidas:
		label_vidas.text = "Vidas: " + str(vidas_jugador) + " vs " + str(vidas_oponente)
	
	if label_microjuego:
		label_microjuego.text = "Microjuego: " + microjuego_actual
	
	if label_oponente:
		label_oponente.text = "Oponente: " + str(vidas_oponente) + " vidas"
	
	if progress_bar:
		progress_bar.value = (vidas_jugador / 3.0) * 100.0

func actualizar_timer():
	if timer_display:
		timer_display.text = "Tiempo: " + str(int(tiempo_restante)) + "s"

func reiniciar_contador():
	vidas_jugador = 3
	vidas_oponente = 3
	microjuego_actual = ""
	tiempo_restante = 0.0
	partida_activa = true
	
	actualizar_display()
	print("🔄 Contador reiniciado")

func set_microjuego(nombre: String):
	microjuego_actual = nombre
	actualizar_display()

func get_vidas_jugador() -> int:
	return vidas_jugador

func get_vidas_oponente() -> int:
	return vidas_oponente

func is_partida_activa() -> bool:
	return partida_activa