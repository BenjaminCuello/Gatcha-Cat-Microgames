extends Control
signal finished(success)
signal microjuego_superado
signal microjuego_fallado

# Variables de dificultad
var nivel_dificultad = 1
var tiempo_limite = 3.0  # 🔧 Nivel 1 = 3 segundos

var clicks_necesarios = 0
var clicks_actuales = 0
var terminado := false

@onready var timer = $Timer
@onready var texto = $TextoInstruccion
@onready var gato = $Gato
@onready var lata = $Lata

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			tiempo_limite = 3.0
		2:
			tiempo_limite = 2.8
		3:
			tiempo_limite = 2.5
		4:
			tiempo_limite = 2.2
		5:
			tiempo_limite = 2.0
		6:
			tiempo_limite = 1.8
		7:
			tiempo_limite = 1.5
		8:
			tiempo_limite = 1.2

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo límite:", tiempo_limite)

func _ready():
    set_process_input(true)
    terminado = false
    clicks_actuales = 0

    # Elegir clicks aleatoriamente entre 15, 16 o 17
    var opciones = [15, 16, 17]
    clicks_necesarios = opciones.pick_random()

    texto.text = "¡Presiona A rápido!"
    texto.visible = true

    # Cargar imágenes
    gato.texture = preload("res://Microjuegos/Cuello/16_Tecla gatuna/Sprites/gatobocacerrada.png")
    lata.texture = preload("res://Microjuegos/Ramiro/21_¡Abrelatas!/Sprites/lata.png")

	# 🔧 Usar tiempo según dificultad
	timer.start(tiempo_limite)

    # Ocultar el texto después de 0.5 s
    await get_tree().create_timer(0.5).timeout
    texto.visible = false

func _input(event):
    if terminado:
        return

    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            return

        if event.keycode == KEY_A:
            clicks_actuales += 1

            # Animación de shake de la lata
            var original_pos = lata.position
            var tween = create_tween()
            tween.tween_property(lata, "position", original_pos + Vector2(6, -4), 0.05)
            tween.tween_property(lata, "position", original_pos + Vector2(-5, 3), 0.05)
            tween.tween_property(lata, "position", original_pos + Vector2(4, -2), 0.05)
            tween.tween_property(lata, "position", original_pos, 0.05)

            if clicks_actuales >= clicks_necesarios:
                victoria()

func _on_Timer_timeout():
    if terminado:
        return

    if clicks_actuales < clicks_necesarios:
        derrota()
        
    else:
        victoria()

func victoria():
    if terminado: return
    terminado = true

    texto.text = "¡Lo lograste!"
    texto.visible = true
    gato.texture = preload("res://Microjuegos/Cuello/16_Tecla gatuna/Sprites/gatofelix.png")
    await get_tree().create_timer(1.0).timeout
    emit_signal("finished", true)
    emit_signal("microjuego_superado")


func derrota():
    if terminado: return
    terminado = true

    texto.text = "¡Muy lento!"
    texto.visible = true
    gato.texture = preload("res://Microjuegos/Cuello/16_Tecla gatuna/Sprites/gatotriste.png")
    await get_tree().create_timer(1.0).timeout
    emit_signal("finished", false)
    emit_signal("microjuego_fallado")
