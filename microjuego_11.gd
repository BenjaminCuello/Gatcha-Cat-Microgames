extends Node2D
signal finished(success)
# Variables del juego
var vida_muneco = 100
var tiempo_restante = 8
var teclas_juego = {"A": KEY_A, "S": KEY_S, "D": KEY_D, "F": KEY_F}  # Mapeando teclas
var tecla_actual = ""
var terminado := false

# Referencias a nodos
@onready var barra_vida = $UI/barra_vida
@onready var label_temporizador = $UI/temporizador
@onready var label_tecla_actual = $UI/LabelTeclaActual
@onready var temporizador = $TiempoJuego
@onready var gato = $gato
@onready var muneco = $muñeco

# Variables para animación
var gato_posicion_original = Vector2()
var gato_posicion_mordida = Vector2()
var muneco_posicion_original = Vector2()

# Posiciones para animaciones finales
var gato_posicion_victoria = Vector2()
var muneco_posicion_derrota = Vector2()

# Variables para explosión
var particulas_explosion = null

func _ready():
	# Inicializar el juego
	randomize()
	
	# Guardar posiciones originales
	gato_posicion_original = gato.position
	muneco_posicion_original = muneco.position
	
	# Posición para el mordisco normal
	gato_posicion_mordida = gato.position - Vector2(10, 0)  # Ajusta según tu diseño
	
	# Posiciones para animación de victoria
	gato_posicion_victoria = gato.position + Vector2(50, 0)  # El gato se mueve hacia la derecha
	muneco_posicion_derrota = muneco.position + Vector2(0, 30)  # El muñeco cae
	
	# Crear sistema de partículas para la explosión
	crear_particulas_explosion()
	
	# Conectar señal del temporizador
	temporizador.connect("timeout", Callable(self, "_on_tiempo_juego_timeout"))
	
	# Iniciar juego
	actualizar_barra_vida()
	actualizar_temporizador()
	generar_nueva_tecla()
	
	# Configurar temporizador para actualizar la cuenta regresiva
	var timer_actualizacion = Timer.new()
	add_child(timer_actualizacion)
	timer_actualizacion.wait_time = 1.0
	timer_actualizacion.connect("timeout", Callable(self, "_on_timer_actualizacion_timeout"))
	timer_actualizacion.start()

# Creamos el sistema de partículas para la explosión
func crear_particulas_explosion():
	particulas_explosion = CPUParticles2D.new()
	add_child(particulas_explosion)
	
	# Configurar partículas para una explosión SÚPER exagerada estilo Minecraft
	particulas_explosion.emitting = false
	particulas_explosion.amount = 150        # Muchas más partículas
	particulas_explosion.lifetime = 1.5      # Duran más tiempo
	particulas_explosion.one_shot = true
	particulas_explosion.explosiveness = 1.0  # Explosividad máxima
	particulas_explosion.spread = 180.0
	particulas_explosion.gravity = Vector2(0, 120)  # Más gravedad
	particulas_explosion.initial_velocity_min = 100  # Velocidad inicial mayor
	particulas_explosion.initial_velocity_max = 250  # Velocidad máxima mucho mayor
	particulas_explosion.scale_amount_min = 4.0      # Partículas más grandes
	particulas_explosion.scale_amount_max = 8.0      # Algunas partículas enormes
	particulas_explosion.color = Color(1.0, 0.2, 0.2)  # Rojo más intenso
	
	# Añadir efecto de damping para que las partículas se frenen gradualmente
	particulas_explosion.damping_min = 10.0
	particulas_explosion.damping_max = 30.0
	
	# Colores más vibrantes y variados
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.2, 0.2))     # Rojo brillante
	gradient.add_point(0.2, Color(1.0, 0.5, 0.0))     # Naranja intenso
	gradient.add_point(0.4, Color(1.0, 1.0, 0.0))     # Amarillo brillante
	gradient.add_point(0.6, Color(0.9, 0.7, 0.1))     # Dorado
	gradient.add_point(0.8, Color(0.7, 0.3, 0.0))     # Marrón
	gradient.add_point(1.0, Color(0.4, 0.4, 0.4))     # Gris humo
	
	particulas_explosion.color_ramp = gradient

# Procesamos la entrada del teclado
func _input(event):
	if terminado:
		return
	
	if event is InputEventKey and event.pressed:
		procesar_tecla_presionada(event.keycode)

func procesar_tecla_presionada(codigo_tecla):
	# Verificar si la tecla presionada corresponde a la tecla actual
	var tecla_correcta = false
	
	for tecla in teclas_juego.keys():
		if teclas_juego[tecla] == codigo_tecla and tecla == tecla_actual:
			tecla_correcta = true
			break
	
	if tecla_correcta:
		# Tecla correcta presionada
		animar_mordisco()
		reducir_vida_muneco()
		generar_nueva_tecla()

func generar_nueva_tecla():
	# Seleccionar una tecla aleatoria de nuestras opciones
	var teclas = teclas_juego.keys()
	tecla_actual = teclas[randi() % teclas.size()]
	
	# Actualizar la etiqueta para mostrar qué tecla se debe presionar
	label_tecla_actual.text = "¡Presiona la tecla " + tecla_actual + "!"
	
	# Efectos visuales para destacar la nueva tecla
	var tween = create_tween()
	tween.tween_property(label_tecla_actual, "modulate", Color(1, 1, 0), 0.2)  # Amarillo
	tween.tween_property(label_tecla_actual, "modulate", Color(1, 1, 1), 0.2)  # Blanco

func reducir_vida_muneco():
	# Reducir la vida del muñeco y verificar si ha sido derrotado
	vida_muneco -= 34
	
	# Asegurar que funcione la actualización de la barra de vida
	if vida_muneco <= 0:
		vida_muneco = 0
		finalizar_juego(true)
	
	# Actualizar la barra de vida visualmente
	actualizar_barra_vida()

func actualizar_barra_vida():
	# Forzar la actualización de la barra de vida
	if barra_vida:
		barra_vida.value = vida_muneco
		# Añadir efecto visual para enfatizar el cambio
		var tween = create_tween()
		tween.tween_property(barra_vida, "modulate", Color(1, 0, 0), 0.1)  # Rojo
		tween.tween_property(barra_vida, "modulate", Color(1, 1, 1), 0.1)  # Normal

func actualizar_temporizador():
	label_temporizador.text = "Tiempo: " + str(tiempo_restante)

func _on_timer_actualizacion_timeout():
	if terminado:
		return
		
	tiempo_restante -= 1
	if tiempo_restante <= 0:
		tiempo_restante = 0
		actualizar_temporizador()
		finalizar_juego(false)
	else:
		actualizar_temporizador()

func _on_tiempo_juego_timeout():
	finalizar_juego(false)

func finalizar_juego(victoria):
	if terminado:
		return
		
	terminado = true
	temporizador.stop()
	
	# Ocultar el indicador de tecla actual
	label_tecla_actual.visible = false
	
	# Detener todos los temporizadores
	for child in get_children():
		if child is Timer and child != temporizador:
			child.stop()
	
	# Asegurar que el tiempo no sea negativo
	tiempo_restante = max(0, tiempo_restante)
	actualizar_temporizador()
	
	# Ejecutar la animación correspondiente
	if victoria:
		animar_victoria_gato()
	else:
		animar_derrota_gato()

func animar_victoria_gato():
	# Animación de victoria: el gato derrota al muñeco
	
	# Parte 1: Mordisco final más fuerte
	var tween = create_tween()
	tween.tween_property(gato, "position", gato_posicion_mordida - Vector2(5, 0), 0.2)
	tween.tween_callback(Callable(self, "activar_explosion"))
	
	# Parte 2: El gato celebra después de que el muñeco explote
	tween.tween_property(gato, "position", gato_posicion_victoria, 0.5)
	tween.tween_property(gato, "rotation_degrees", -10, 0.1)
	tween.tween_property(gato, "rotation_degrees", 10, 0.1)
	tween.tween_property(gato, "rotation_degrees", 0, 0.1)
	
	# Esperamos que termine la animación antes de mostrar el mensaje
	tween.tween_callback(Callable(self, "mostrar_mensaje_final").bind(true))

func activar_explosion():
	# Posicionar partículas en el muñeco
	particulas_explosion.position = muneco.position
	
	# Ocultar al muñeco (simular que desaparece)
	muneco.visible = false
	
	# Reproducir sonido de explosión (si tienes un nodo AudioStreamPlayer)
	if has_node("SonidoExplosion"):
		get_node("SonidoExplosion").play()
	
	# Activar las partículas
	particulas_explosion.emitting = true
	
	# Crear partículas adicionales para mayor dramatismo
	var particulas_secundarias = CPUParticles2D.new()
	add_child(particulas_secundarias)
	particulas_secundarias.position = muneco.position
	particulas_secundarias.emitting = true
	particulas_secundarias.amount = 20
	particulas_secundarias.lifetime = 2.0
	particulas_secundarias.one_shot = true
	particulas_secundarias.explosiveness = 1.0
	particulas_secundarias.spread = 180.0
	particulas_secundarias.gravity = Vector2(0, 50)
	particulas_secundarias.initial_velocity_min = 50
	particulas_secundarias.initial_velocity_max = 120
	particulas_secundarias.scale_amount_min = 10.0
	particulas_secundarias.scale_amount_max = 15.0
	particulas_secundarias.color = Color(0.2, 0.2, 0.2, 0.7)  # Humo gris oscuro
	
	# Crear onda expansiva (círculo que se expande)
	var onda = Sprite2D.new()
	add_child(onda)
	onda.position = muneco.position
	# Si tienes una textura de círculo puedes usarla aquí
	# onda.texture = preload("res://circle.png") 
	# Si no tienes, usa un color semitransparente
	var color_onda = Color(1, 0.7, 0, 0.5)  # Naranja semitransparente
	onda.modulate = color_onda
	onda.scale = Vector2(0.1, 0.1)  # Comienza pequeño
	
	# Animar la onda expansiva
	var tween_onda = create_tween()
	tween_onda.tween_property(onda, "scale", Vector2(5, 5), 0.5)
	tween_onda.parallel().tween_property(onda, "modulate", Color(color_onda.r, color_onda.g, color_onda.b, 0), 0.5)
	tween_onda.tween_callback(Callable(onda, "queue_free"))
	
	# Efectos adicionales de explosión tipo Minecraft
	# Efecto de sacudida de cámara EXAGERADO
	if has_node("Camera2D"):
		var cam = get_node("Camera2D")
		var tween_cam = create_tween()
		var original_pos = cam.position
		tween_cam.tween_property(cam, "position", original_pos + Vector2(15, 15), 0.05)
		tween_cam.tween_property(cam, "position", original_pos + Vector2(-15, -12), 0.05)
		tween_cam.tween_property(cam, "position", original_pos + Vector2(10, -8), 0.05)
		tween_cam.tween_property(cam, "position", original_pos + Vector2(-5, 10), 0.05)
		tween_cam.tween_property(cam, "position", original_pos, 0.1)
		
	# Crear un efecto de flash blanco en la pantalla
	var flash = ColorRect.new()
	add_child(flash)
	flash.color = Color(1, 1, 1, 0.7)  # Blanco semitransparente
	flash.size = get_viewport_rect().size
	flash.position = Vector2(0, 0)
		
	var tween_flash = create_tween()
	tween_flash.tween_property(flash, "color", Color(1, 1, 1, 0), 0.5)  # Desvanecerse
	tween_flash.tween_callback(Callable(flash, "queue_free"))

func animar_derrota_gato():
	# Animación de derrota: el gato no logra derrotar al muñeco a tiempo
	
	# Parte 1: El gato se mueve hacia atrás frustrado
	var tween = create_tween()
	tween.tween_property(gato, "position", gato_posicion_original + Vector2(-30, 0), 0.3)
	
	# Parte 2: El muñeco parece recuperarse
	tween.parallel().tween_property(muneco, "modulate", Color(0.0, 1.0, 0.0), 0.5)  # Verde = recuperación
	tween.parallel().tween_property(muneco, "rotation_degrees", -5, 0.2)
	tween.tween_property(muneco, "rotation_degrees", 5, 0.2)
	tween.tween_property(muneco, "rotation_degrees", 0, 0.2)
	
	# Parte 3: El gato muestra frustración
	tween.tween_property(gato, "rotation_degrees", -5, 0.1)
	tween.tween_property(gato, "rotation_degrees", 5, 0.1)
	tween.tween_property(gato, "rotation_degrees", 0, 0.1)
	
	# Esperamos que termine la animación antes de mostrar el mensaje
	tween.tween_callback(Callable(self, "mostrar_mensaje_final").bind(false))

func mostrar_mensaje_final(victoria):
	# Mostrar mensaje de resultado
	var mensaje = "¡VICTORIA!" if victoria else "¡TIEMPO AGOTADO!"
	var resultado = Label.new()
	resultado.text = mensaje
	resultado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resultado.size = Vector2(400, 100)
	resultado.position = Vector2(get_viewport_rect().size.x / 2 - 200, get_viewport_rect().size.y / 2 - 50)
	
	# Crear y asignar LabelSettings con tamaño de fuente personalizado
	var label_settings = LabelSettings.new()
	label_settings.font_size = 80  # ← aquí ajustas el tamaño de fuente
	resultado.label_settings = label_settings
	
	# Añadir efecto de aparición gradual
	resultado.modulate = Color(1, 1, 1, 0)
	add_child(resultado)
	
	var tween = create_tween()
	tween.tween_property(resultado, "modulate", Color(1, 1, 1, 1), 1.0)
	
	emit_signal("finished", true)
func animar_mordisco():
	# Animación de mordisco durante el juego
	var tween = create_tween()
	tween.tween_property(gato, "position", gato_posicion_mordida, 0.1)
	tween.tween_property(gato, "position", gato_posicion_original, 0.1)
	
	# Animación del muñeco recibiendo daño
	var tween_muneco = create_tween()
	tween_muneco.tween_property(muneco, "modulate", Color(1, 0, 0), 0.1)
	tween_muneco.tween_property(muneco, "modulate", Color(1, 1, 1), 0.1)
