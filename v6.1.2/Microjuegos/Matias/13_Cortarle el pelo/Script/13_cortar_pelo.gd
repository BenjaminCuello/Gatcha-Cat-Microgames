# HairCuttingGame.gd
extends Control

# Señal que emite al terminar el juego
signal finished(victory: bool)
signal microjuego_superado
signal microjuego_fallado

# Variables de dificultad
var nivel_dificultad = 1
var time_limit = 5.0  # 🔧 Nivel 1 = 5 segundos

# Secuencia correcta de teclas (se genera aleatoriamente)
var correct_sequence = []
var available_keys = ["A", "S", "D", "F"]
var current_input = []
var game_active = true
var game_played = false

# Timer variables
var time_remaining = 0.0
var timer_active = false

# Referencias a nodos UI
@onready var instruction_label = $InstructionLabel
@onready var sequence_label = $SequenceLabel
@onready var input_label = $InputLabel
@onready var timer_label = $TimerLabel
@onready var cat_sprite = $CatSprite
@onready var scissors_sprite = $ScissorsSprite

# Texturas del gato
@export var cat_messy_texture: Texture2D  # Gato con pelo desordenado
@export var cat_neat_texture: Texture2D   # Gato con pelo peinado

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			time_limit = 5.0
		2:
			time_limit = 4.5
		3:
			time_limit = 4.0
		4:
			time_limit = 3.5
		5:
			time_limit = 3.0
		6:
			time_limit = 2.5
		7:
			time_limit = 2.0
		8:
			time_limit = 1.5

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo límite:", time_limit)

func _ready():
    # Solo permitir que el juego se ejecute una vez
    if game_played:
        return
        
    setup_game()

func setup_game():
	# Generar secuencia aleatoria de 3 teclas
	generate_random_sequence()
	
	# Configurar la interfaz inicial
	instruction_label.text = "¡Corta el pelo del gato siguiendo la secuencia!"
	sequence_label.text = "Secuencia: " + " → ".join(correct_sequence)
	input_label.text = "Tu entrada: "
	
	# 🔧 Inicializar timer con tiempo según dificultad
	time_remaining = time_limit
	timer_active = true
	update_timer_display()
	
	# Mostrar el gato con pelo desordenado
	if cat_sprite and cat_messy_texture:
		cat_sprite.texture = cat_messy_texture
		cat_sprite.scale = Vector2(0.4, 0.4)  # Hacer más grande 	
		cat_sprite.position = Vector2(950, 560)  # Reposicionar
		cat_sprite.visible = true
	
	# Mostrar las tijeras
	if scissors_sprite:
		scissors_sprite.visible = true
	
	print("Juego iniciado. Presiona las teclas en orden: ", correct_sequence)
	print("Tienes ", time_limit, " segundos para completarlo")

func generate_random_sequence():
    # Limpiar secuencia anterior
    correct_sequence.clear()
    
    # Generar 3 teclas aleatorias
    for i in range(3):
        var random_key = available_keys[randi() % available_keys.size()]
        correct_sequence.append(random_key)
    
    print("Nueva secuencia generada: ", correct_sequence)

func _process(delta):
    # Actualizar timer si está activo
    if timer_active and game_active:
        time_remaining -= delta
        update_timer_display()
        
        # Si se acabó el tiempo
        if time_remaining <= 0:
            timer_active = false
            end_game_timeout()
            emit_signal("finished", false)
            emit_signal("microjuego_fallado")


func update_timer_display():
    if timer_label:
        var seconds = max(0, ceil(time_remaining))
        timer_label.text = "Tiempo: " + str(seconds) + "s"
        
        # Cambiar color cuando queda poco tiempo
        if time_remaining <= 2.0:
            timer_label.modulate = Color.RED
        elif time_remaining <= 3.0:
            timer_label.modulate = Color.ORANGE
        else:
            timer_label.modulate = Color.WHITE

func end_game_timeout():
    instruction_label.text = "¡Tiempo agotado! El gato se escapó antes de que terminaras"
    instruction_label.modulate = Color.RED
    animate_cat_angry()
    game_active = false
    game_played = true
    
    # Emitir señal de derrota después de un breve delay
    await get_tree().create_timer(1.5).timeout
    emit_signal("finished", false)

func _input(event):
    # Solo procesar input si el juego está activo y no se ha jugado antes
    if not game_active or game_played:
        return
        
    # Detectar teclas presionadas
    if event is InputEventKey and event.pressed:
        var key_pressed = ""
        
        # Mapear las teclas a strings
        match event.keycode:
            KEY_A:
                key_pressed = "A"
            KEY_S:
                key_pressed = "S"
            KEY_D:
                key_pressed = "D"
            KEY_F:
                key_pressed = "F"
        
        # Si se presionó una tecla válida
        if key_pressed in available_keys:
            process_input(key_pressed)

func process_input(key: String):
    # Añadir la tecla presionada a la entrada actual
    current_input.append(key)
    
    # Actualizar la UI
    input_label.text = "Tu entrada: " + " → ".join(current_input)
    
    # Verificar si la entrada es correcta hasta ahora
    for i in range(current_input.size()):
        if current_input[i] != correct_sequence[i]:
            # Entrada incorrecta - derrota
            end_game(false)
            return
    
    # Si completamos la secuencia correctamente
    if current_input.size() == correct_sequence.size():
        # Victoria
        end_game(true)

func end_game(victory: bool):
    game_active = false
    game_played = true
    timer_active = false  # Detener el timer
    
    if victory:
        instruction_label.text = "¡Perfecto! Le cortaste el pelo correctamente al gato"
        instruction_label.modulate = Color.GREEN
        timer_label.modulate = Color.GREEN
        # Cambiar sprite del gato a peinado
        if cat_sprite and cat_neat_texture:
            cat_sprite.texture = cat_neat_texture
        # Animación de tijeras cortando
        animate_scissors_success()
    else:
        instruction_label.text = "¡Oh no! Cortaste mal el pelo. El gato está molesto"
        instruction_label.modulate = Color.RED
        timer_label.modulate = Color.RED
        # El gato mantiene el pelo desordenado y se anima molesto
        animate_cat_angry()
    
    # Emitir la señal después de un breve delay
    await get_tree().create_timer(1.5).timeout
    emit_signal("finished", victory)
    if victory:
        emit_signal("microjuego_superado")
    else:
        emit_signal("microjuego_fallado")

    emit_signal("finished", victory)

func animate_scissors_success():
    # Animación realista de tijeras cortando el pelo del gato
    if scissors_sprite:
        # Posición inicial de las tijeras
        var original_position = scissors_sprite.position
        var cat_position = cat_sprite.position if cat_sprite else Vector2(300, 200)
        
        var tween = create_tween()
        
        # Secuencia de cortes realistas (sin parallel para evitar conflictos)
        # 1. Mover tijeras hacia la cabeza del gato
        tween.tween_property(scissors_sprite, "position", cat_position + Vector2(-30, -50), 0.4)
        
        # 2. Primer corte - abrir y cerrar tijeras
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(15), 0.2)
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(-15), 0.15)
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(15), 0.15)
        
        # 3. Mover a segunda posición de corte
        tween.tween_property(scissors_sprite, "position", cat_position + Vector2(30, -50), 0.3)
        
        # 4. Segundo corte
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(-20), 0.15)
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(20), 0.15)
        
        # 5. Mover a tercera posición (lateral)
        tween.tween_property(scissors_sprite, "position", cat_position + Vector2(-40, -20), 0.3)
        
        # 6. Tercer corte
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(10), 0.15)
        tween.tween_property(scissors_sprite, "rotation", deg_to_rad(-10), 0.15)
        
        # 7. Regresar a posición original con movimiento suave
        tween.tween_property(scissors_sprite, "position", original_position, 0.5)
        tween.tween_property(scissors_sprite, "rotation", 0, 0.3)
        
        # 8. Efecto de "satisfacción" - pequeño rebote final
        tween.tween_property(scissors_sprite, "scale", Vector2(1.1, 1.1), 0.1)
        tween.tween_property(scissors_sprite, "scale", Vector2(1.0, 1.0), 0.1)

func animate_cat_angry():
    # Animación simple de gato molesto
    if cat_sprite:
        var tween = create_tween()
        tween.tween_property(cat_sprite, "modulate", Color.RED, 0.2)
        tween.tween_property(cat_sprite, "modulate", Color.WHITE, 0.2)
        tween.tween_property(cat_sprite, "modulate", Color.RED, 0.2)
        tween.tween_property(cat_sprite, "modulate", Color.WHITE, 0.2)

# Función para reiniciar el juego (si necesitas llamarla externamente)
func reset_game():
    game_played = false
    game_active = true
    current_input.clear()
    instruction_label.modulate = Color.WHITE
    # Restaurar gato con pelo desordenado
    if cat_sprite and cat_messy_texture:
        cat_sprite.texture = cat_messy_texture
    setup_game()
