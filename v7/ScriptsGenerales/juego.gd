extends Node

# Enumeración para los modos de juego
enum ModoJuego {
	HISTORIA,
	INFINITO
}

# Variables del juego
var vidas = 3
var microjuego_actual = 0
var modo_actual = ModoJuego.HISTORIA

# Variables para el modo infinito
var nivel_dificultad = 1
var microjuegos_completados_infinito = 0
var ciclos_completados = 0

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
	"res://Microjuegos/Matias/13_Cortarle el pelo/Escena/13_cortarPelo.tscn",
	"res://Microjuegos/Matias/14_Gato laser/Escena/14_gato laser.tscn",
	"res://Microjuegos/Matias/15_Anvorgueso/Escena/Pincipal.tscn",
	"res://Microjuegos/Ramiro/21_¡Abrelatas!/Escena/Abrelatas (3).tscn",
	"res://Microjuegos/Ramiro/22_Atrápalo/Escena/Atrapalo (6).tscn"
]

# Lista para controlar qué microjuegos ya se han jugado (para evitar repeticiones)
var microjuegos_jugados = []

# Función para obtener microjuego según el modo
func obtener_siguiente_microjuego() -> String:
	match modo_actual:
		ModoJuego.HISTORIA:
			return obtener_microjuego_historia()
		ModoJuego.INFINITO:
			return obtener_microjuego_infinito()
		_:
			return obtener_microjuego_historia()

# Función para obtener microjuego en modo historia (sin repetir, una sola vez cada uno)
func obtener_microjuego_historia() -> String:
	# Crear lista de microjuegos disponibles (no jugados)
	var disponibles = []
	for microjuego in lista_microjuegos:
		if not microjuego in microjuegos_jugados:
			disponibles.append(microjuego)
	
	# Si no hay disponibles, significa que ya se jugaron todos
	if disponibles.size() == 0:
		print("Todos los microjuegos completados en modo Historia!")
		return ""  # Retornar vacío indica que terminó el modo historia
	
	# Elegir uno al azar de los disponibles
	var elegido = disponibles.pick_random()
	microjuegos_jugados.append(elegido)
	microjuego_actual += 1
	
	print("Modo Historia - Microjuego ", microjuego_actual, "/", lista_microjuegos.size(), ": ", elegido)
	
	return elegido

# Función para obtener microjuego en modo infinito
func obtener_microjuego_infinito() -> String:
	# Si ya se jugaron todos los microjuegos en este ciclo, reiniciar lista y aumentar dificultad
	if microjuegos_jugados.size() >= lista_microjuegos.size():
		microjuegos_jugados.clear()
		ciclos_completados += 1
		# Aumentar dificultad cada ciclo completo (máximo nivel 8)
		if nivel_dificultad < 8:
			nivel_dificultad += 1
		print("¡Ciclo ", ciclos_completados, " completado! Nivel de dificultad: ", nivel_dificultad)
	
	# Crear lista de microjuegos disponibles (no jugados en este ciclo)
	var disponibles = []
	for microjuego in lista_microjuegos:
		if not microjuego in microjuegos_jugados:
			disponibles.append(microjuego)
	
	# Elegir uno al azar de los disponibles
	var elegido = disponibles.pick_random()
	microjuegos_jugados.append(elegido)
	microjuegos_completados_infinito += 1
	
	print("Modo Infinito - Microjuego ", microjuegos_completados_infinito, " (Ciclo ", ciclos_completados + 1, ", Nivel ", nivel_dificultad, "): ", elegido)
	
	return elegido

# Función para obtener el nivel de dificultad actual que se enviará al microjuego
func obtener_nivel_dificultad_actual() -> int:
	match modo_actual:
		ModoJuego.HISTORIA:
			return 1  # Siempre nivel 1 en historia
		ModoJuego.INFINITO:
			return nivel_dificultad  # Nivel actual en infinito (1-8)
		_:
			return 1

# Función para verificar si el modo historia está completo
func es_historia_completa() -> bool:
	return modo_actual == ModoJuego.HISTORIA and microjuegos_jugados.size() >= lista_microjuegos.size()

# Función para configurar modo historia
func iniciar_modo_historia():
	modo_actual = ModoJuego.HISTORIA
	vidas = 3
	microjuego_actual = 0
	nivel_dificultad = 1
	microjuegos_jugados.clear()
	print("=== MODO HISTORIA INICIADO ===")
	print("Total de microjuegos a completar: ", lista_microjuegos.size())
	print("Cada microjuego se jugará solo una vez")
	print("Nivel de dificultad fijo: 1")

# Función para configurar modo infinito
func iniciar_modo_infinito():
	modo_actual = ModoJuego.INFINITO
	vidas = 3
	microjuego_actual = 0
	nivel_dificultad = 1
	microjuegos_completados_infinito = 0
	ciclos_completados = 0
	microjuegos_jugados.clear()
	print("=== MODO INFINITO INICIADO ===")
	print("Total de microjuegos por ciclo: ", lista_microjuegos.size())
	print("Los microjuegos se repetirán infinitamente")
	print("La dificultad aumenta cada ciclo completo (máximo nivel 8)")

# Función para reiniciar (mantener compatibilidad)
func reiniciar():
	match modo_actual:
		ModoJuego.HISTORIA:
			iniciar_modo_historia()
		ModoJuego.INFINITO:
			iniciar_modo_infinito()

# Función para verificar si el juego debe continuar
func debe_continuar() -> bool:
	match modo_actual:
		ModoJuego.HISTORIA:
			# En historia, continúa si tienes vidas Y no has completado todos los microjuegos
			return vidas > 0 and not es_historia_completa()
		ModoJuego.INFINITO:
			# En infinito, continúa mientras tengas vidas (es infinito)
			return vidas > 0
		_:
			return false

# Función para obtener información del estado actual
func obtener_info_estado() -> Dictionary:
	var info = {
		"modo": "Historia" if modo_actual == ModoJuego.HISTORIA else "Infinito",
		"vidas": vidas,
		"nivel_dificultad": nivel_dificultad,
		"total_microjuegos": lista_microjuegos.size(),
		"microjuegos_jugados_en_ciclo": microjuegos_jugados.size()
	}
	
	# Información específica por modo
	if modo_actual == ModoJuego.HISTORIA:
		info["microjuego_actual"] = microjuego_actual
		info["progreso"] = str(microjuego_actual) + "/" + str(lista_microjuegos.size())
		info["historia_completa"] = es_historia_completa()
	else:  # INFINITO
		info["microjuegos_totales_completados"] = microjuegos_completados_infinito
		info["ciclos_completados"] = ciclos_completados
		info["microjuegos_en_ciclo_actual"] = microjuegos_jugados.size()
		info["progreso_ciclo"] = str(microjuegos_jugados.size()) + "/" + str(lista_microjuegos.size())
	
	return info

# Función para mostrar el estado actual (para debugging)
func mostrar_estado():
	var info = obtener_info_estado()
	print("=== ESTADO ACTUAL DEL JUEGO ===")
	for key in info.keys():
		print(key, ": ", info[key])
	print("===============================")
