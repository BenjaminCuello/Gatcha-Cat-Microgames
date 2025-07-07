extends Node2D

signal finished(victory: bool)
signal microjuego_superado
signal microjuego_fallado

@onready var cat = $Cat
@onready var laser = $Laser
@onready var game_timer = $GameTimer
@onready var time_label = $TimeLabel
@onready var instruction_label = $InstructionLabel

var game_duration = 5.0
var laser_contact_time = 0.0
var max_laser_contact = 3.0
var game_active = true

# Sistema de proximidad sensible
var proximity_threshold_close = 100.0  # Distancia "cerca"
var proximity_threshold_very_close = 50.0  # Distancia "muy cerca"
var base_contact_rate = 1.0  # Velocidad base del contador
var close_contact_rate = 2.0  # Velocidad cuando está cerca (2x)
var very_close_contact_rate = 4.0  # Velocidad cuando está muy cerca (4x)

# Variable para el efecto de parpadeo
var blink_timer = 0.0

func _ready():
    # Verificar que todos los nodos existen
    if not cat:
        print("Error: No se encontró el nodo Cat")
        return
    if not laser:
        print("Error: No se encontró el nodo Laser")
        return
    if not game_timer:
        print("Error: No se encontró el nodo GameTimer")
        return
    if not time_label:
        print("Error: No se encontró el nodo TimeLabel")
        return
    if not instruction_label:
        print("Error: No se encontró el nodo InstructionLabel")
        return
    
    game_timer.wait_time = game_duration
    game_timer.timeout.connect(_on_game_timeout)
    game_timer.start()
    
    # Configurar UI
    instruction_label.text = "¡Evita que el gato toque el láser!"
    instruction_label.add_theme_font_size_override("font_size", 64)
    instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    
    cat.global_position = Vector2(100, 100)
    laser.global_position = get_global_mouse_position()

func _process(delta):
    if not game_active:
        return
        
    time_label.text = "Tiempo: " + str(int(game_timer.time_left))
    
    # Control del láser con mouse
    laser.global_position = get_global_mouse_position()
    
    # Sistema de proximidad sensible
    check_laser_contact_with_proximity(delta)

func check_laser_contact_with_proximity(delta):
    # Calcular distancia entre gato y láser
    var distance = cat.global_position.distance_to(laser.global_position)
    
    # Verificar contacto directo
    var laser_areas = laser.get_overlapping_areas()
    var cat_touching = false
    
    for area in laser_areas:
        if area.get_parent() == cat:
            cat_touching = true
            break
    
    # Determinar velocidad del contador según proximidad
    var contact_rate = 0.0
    var proximity_status = ""
    var warning_color = Color.WHITE
    
    if cat_touching:
        # Contacto directo - velocidad máxima (8x)
        contact_rate = very_close_contact_rate * 2
        proximity_status = "¡CONTACTO DIRECTO!"
        warning_color = Color.RED
    elif distance <= proximity_threshold_very_close:
        # Muy cerca - velocidad alta (4x)
        contact_rate = very_close_contact_rate
        proximity_status = "¡MUY CERCA!"
        warning_color = Color.ORANGE_RED
    elif distance <= proximity_threshold_close:
        # Cerca - velocidad media (2x)
        contact_rate = close_contact_rate
        proximity_status = "¡CERCA!"
        warning_color = Color.YELLOW
    
    # Aplicar contador solo si hay proximidad
    if contact_rate > 0:
        laser_contact_time += delta * contact_rate
        
        # Mostrar advertencia con tiempo restante
        var time_remaining = max_laser_contact - laser_contact_time
        if time_remaining > 0:
            instruction_label.text = proximity_status + " Tiempo: " + str("%.1f" % time_remaining)
            instruction_label.modulate = warning_color
            
            # SOLUCIÓN AL ERROR: Usar timer personalizado para parpadeo crítico
            if time_remaining < 1.0:
                blink_timer += delta
                # Parpadear cada 0.15 segundos
                var blink = int(blink_timer / 0.15) % 2 == 0
                instruction_label.modulate = Color.RED if blink else Color.WHITE
        
        # Verificar derrota
        if laser_contact_time >= max_laser_contact:
            end_game(false)
    else:
        # Resetear cuando está lejos
        laser_contact_time = 0.0
        blink_timer = 0.0  # Resetear también el timer de parpadeo
        instruction_label.text = "¡Evita que el gato toque el láser!"
        instruction_label.modulate = Color.WHITE

func _on_game_timeout():
    end_game(true)

func end_game(victory: bool):
    if not game_active:
        return
        
    game_active = false
    game_timer.stop()
    
    if victory:
        instruction_label.text = "¡VICTORIA! Mantuviste al gato alejado"
        instruction_label.modulate = Color.GREEN
    else:
        instruction_label.text = "¡DERROTA! El gato se aburrió con el láser"
        instruction_label.modulate = Color.RED

    emit_signal("finished", victory)
    if victory:
        emit_signal("microjuego_superado")
    else:
        emit_signal("microjuego_fallado")
