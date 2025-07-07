extends Node

# Enum para modos de juego
enum ModoJuego {
	HISTORIA,
	INFINITO
}

# Vida y control de microjuegos
var vidas = 3
var microjuego_actual = 0
var max_microjuegos = 30
var modo_juego_actual = ModoJuego.HISTORIA

# Sistema de dificultad para modo infinito
var microjuegos_jugados = {}  # Diccionario que rastrea cuántas veces se ha jugado cada microjuego
var microjuegos_disponibles = []  # Lista de microjuegos disponibles en la ronda actual
var ronda_actual = 1  # Contador de rondas en modo infinito

# Lista de microjuegos disponibles
var lista_microjuegos = [
	"res://Microjuegos/Andres/26_Atrapa el ratón/Escena/atrapar_raton.tscn",
	"res://Microjuegos/Andres/27_Llamar al gato/Escena/llamarAlGato.tscn",
	"res://Microjuegos/Branco/6_Pesca en hielo/Escena/6_Pesca_Hielo.tscn",
	"res://Microjuegos/Branco/7_Recrear foto/Escena/7_Recrear_Foto.tscn",
	"res://Microjuegos/Branco/8_Surfeando/Escena/8_Surfeando.tscn",
	"res://Microjuegos/Branco/9_Flappy Birds con gatitos/Escena/9_Flappy_cat.tscn",
	"res://Microjuegos/Branco/10_Juego de cartas/Escena/10_Cartas.tscn",
	"res://Microjuegos/Branco/Secreto1/Escena/28_Secreto1.tscn",
	"res://Microjuegos/Cuello/16_Tecla gatuna/Escena/Tecla gatuna (1).tscn",
	"res://Microjuegos/Cuello/18_Gato equilibrio/Escena/Gato equilibrio (2).tscn",
	"res://Microjuegos/Cuello/19_  Baile rítmico/Escena/Baile rítmico (5).tscn",
	"res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn",
	"res://Microjuegos/Emily/3_Apunta y dispara/Escena/main.tscn",
	"res://Microjuegos/Emily/4_Gato guatón/Escena/main.tscn",
	"res://Microjuegos/Emily/5_Encuentra al impostor/Escena/5_Encuentra_Impostor.tscn",
	"res://Microjuegos/Matias/11_Morder al muñeco/Escena/11_Morder_al_muñeco.tscn",
	"res://Microjuegos/Matias/12_Lavarse con la lengua/Escena/12_Gato Lamerse.tscn",
	#"res://Microjuegos/Matias/14_Gato laser/Escena/14_gato laser.tscn",
	#"res://Microjuegos/Matias/15_Anvorgueso/Escena/Pincipal.tscn",
	"res://Microjuegos/Ramiro/21_¡Abrelatas!/Escena/Abrelatas (3).tscn",
	"res://Microjuegos/Ramiro/22_Atrápalo/Escena/Atrapalo (6).tscn"
]
# Elegir uno al azar sin repetir
func obtener_microjuego_aleatorio() -> String:
	if modo_juego_actual == ModoJuego.HISTORIA:
		return obtener_microjuego_historia()
	else:
		return obtener_microjuego_infinito()

# Obtener microjuego para modo historia (sin repetir)
func obtener_microjuego_historia() -> String:
	# Si no hay microjuegos disponibles, reiniciar lista
	if microjuegos_disponibles.is_empty():
		microjuegos_disponibles = lista_microjuegos.duplicate()
	
	# Elegir uno al azar y quitarlo de la lista
	var indice = randi() % microjuegos_disponibles.size()
	var microjuego_elegido = microjuegos_disponibles[indice]
	microjuegos_disponibles.remove_at(indice)
	
	return microjuego_elegido

# Obtener microjuego para modo infinito (con sistema de rondas)
func obtener_microjuego_infinito() -> String:
	# Si no hay microjuegos disponibles, reiniciar lista y aumentar ronda
	if microjuegos_disponibles.is_empty():
		microjuegos_disponibles = lista_microjuegos.duplicate()
		ronda_actual += 1
		print("🔄 Nueva ronda: ", ronda_actual)
	
	# Elegir uno al azar y quitarlo de la lista
	var indice = randi() % microjuegos_disponibles.size()
	var microjuego_elegido = microjuegos_disponibles[indice]
	microjuegos_disponibles.remove_at(indice)
	
	# Actualizar contador de veces jugado
	if not microjuegos_jugados.has(microjuego_elegido):
		microjuegos_jugados[microjuego_elegido] = 0
	microjuegos_jugados[microjuego_elegido] += 1
	
	return microjuego_elegido

# Obtener nivel de dificultad para un microjuego
func obtener_nivel_dificultad(microjuego: String) -> int:
	if modo_juego_actual == ModoJuego.HISTORIA:
		return 1  # Siempre nivel 1 en modo historia
	else:
		# En modo infinito, la dificultad aumenta con cada ronda
		if microjuegos_jugados.has(microjuego):
			return min(microjuegos_jugados[microjuego], 5)  # Máximo nivel 5
		else:
			return 1

# Obtener duración según nivel de dificultad
func obtener_duracion_por_dificultad(nivel: int) -> float:
	match nivel:
		1:
			return 10.0
		2:
			return 8.0
		3:
			return 6.0
		4:
			return 4.0
		5:
			return 2.0
		_:
			return 10.0  # Por defecto

# Reiniciar el juego
func reiniciar():
	vidas = 3
	microjuego_actual = 0
	microjuegos_jugados.clear()
	microjuegos_disponibles.clear()
	ronda_actual = 1

# Configurar modo de juego
func configurar_modo(modo: ModoJuego):
	modo_juego_actual = modo
	reiniciar()
	print("🎮 Modo configurado: ", "HISTORIA" if modo == ModoJuego.HISTORIA else "INFINITO")

# Verificar si el juego debe terminar
func debe_terminar_juego() -> bool:
	if modo_juego_actual == ModoJuego.HISTORIA:
		return microjuego_actual >= max_microjuegos
	else:
		return false  # Modo infinito nunca termina por límite de microjuegos
