extends Node

signal game_over(winner: String)

var puntos := 0
var vidas := 3
const PUNTOS_PARA_EVENTO := 5
var puntos_sin_evento := 0

var oponente := ""
var match_id := ""

@onready var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	print("Juego estándar multijugador iniciado")

func on_microjuego_superado():
	puntos += 1
	puntos_sin_evento += 1
	print("Puntos: ", puntos)
	
	if puntos_sin_evento >= PUNTOS_PARA_EVENTO:
		puntos_sin_evento = 0
		_enviar_evento_aleatorio()

func on_microjuego_fallado():
	vidas -= 1
	print("Vidas restantes: ", vidas)
	if vidas <= 0:
		_enviar_derrota()
		emit_signal("game_over", oponente)

func _enviar_evento_aleatorio():
	var efectos = ["smoke", "fast", "less-time"]
	var evento = efectos[rng.randi_range(0, efectos.size() - 1)]
	print("Enviando evento al oponente: ", evento)
	
	var payload = {
		"event": "trigger-hazard",
		"data": {
			"matchId": match_id,
			"to": oponente,
			"hazard": evento
		}
	}
	_enviar_evento_servidor(payload)

func _enviar_derrota():
	var payload = {
		"event": "player-lost",
		"data": {
			"matchId": match_id,
			"to": oponente
		}
	}
	_enviar_evento_servidor(payload)

func recibir_evento(evento: Dictionary):
	match evento.get("event", ""):
		"trigger-hazard":
			var hazard = evento["data"].get("hazard", "")
			print("Evento de dificultad recibido: ", hazard)
			aplicar_dificultad(hazard)
		"player-lost":
			print("Tu oponente ha perdido. Has ganado la partida!")
			emit_signal("game_over", Global.username)

func aplicar_dificultad(tipo: String):
	match tipo:
		"smoke":
			# Agrega efecto de humo en pantalla
			print("Aplicando efecto: humo")
		"fast":
			# Aumenta velocidad del microjuego
			print("Aplicando efecto: velocidad")
		"less-time":
			# Reduce el tiempo disponible para el siguiente microjuego
			print("Aplicando efecto: menos tiempo")

func _enviar_evento_servidor(payload: Dictionary):
	# 🔧 CORREGIDO: Verificar si ChatManager existe
	var chat_manager = get_node_or_null("/root/ChatManager")
	if chat_manager and chat_manager.has_method("enviar_evento_personalizado"):
		chat_manager.enviar_evento_personalizado(payload)
	else:
		print("ChatManager no encontrado o método no disponible")
