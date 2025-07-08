extends Control
signal finished(success)
signal microjuego_superado
signal microjuego_fallado

# Variables de dificultad
var nivel_dificultad = 1
var duracion_movimiento_min = 2.0  # 🔧 Velocidad mínima según nivel
var duracion_movimiento_max = 3.5  # 🔧 Velocidad máxima según nivel

var atrapado := false
var terminado := false

@onready var raton = $Raton
@onready var texto = $TextoInstruccion
@onready var timer = $TimerJuego
@onready var zona_captura = $ZonaCaptura

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			duracion_movimiento_min = 2.0
			duracion_movimiento_max = 3.5
		2:
			duracion_movimiento_min = 1.8
			duracion_movimiento_max = 3.0
		3:
			duracion_movimiento_min = 1.5
			duracion_movimiento_max = 2.5
		4:
			duracion_movimiento_min = 1.2
			duracion_movimiento_max = 2.0
		5:
			duracion_movimiento_min = 1.0
			duracion_movimiento_max = 1.8
		6:
			duracion_movimiento_min = 0.8
			duracion_movimiento_max = 1.5
		7:
			duracion_movimiento_min = 0.6
			duracion_movimiento_max = 1.2
		8:
			duracion_movimiento_min = 0.4
			duracion_movimiento_max = 0.8

	print("Nivel configurado:", nivel_dificultad)
	print("Velocidad ratón - Min:", duracion_movimiento_min, "s, Max:", duracion_movimiento_max, "s")

func _ready():
    atrapado = false
    terminado = false

    raton.position = Vector2(-100, 300)
    mover_raton()

    # Mostrar instrucción inicial (ya viene escrita desde el editor)
    texto.visible = true

    # Ocultarla después de 1 segundo
    await get_tree().create_timer(1.0).timeout
    texto.visible = false

    # Iniciar el tiempo del microjuego
    timer.start()

func mover_raton():
    var destino = Vector2(1200, 300)

	# 🔧 Movimiento con duración según dificultad
	var duracion = randf_range(duracion_movimiento_min, duracion_movimiento_max)

    var tween = create_tween()
    tween.tween_property(raton, "position", destino, duracion).set_trans(Tween.TRANS_LINEAR)

	print("Ratón moviéndose en ", duracion, " segundos")

func _input(event):
    if atrapado or terminado:
        return

    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            return  # Ignora ESC

        if event.as_text().to_upper() == "A":
            if raton.get_global_rect().intersects(zona_captura.get_global_rect()):
                atrapado = true
                victoria()
            else:
                atrapado = true
                derrota()

func _on_TimerJuego_timeout():
    if not atrapado and not terminado:
        derrota()

func victoria():
    if terminado:
        return
    terminado = true

    texto.text = "¡Lo atrapaste!"
    texto.visible = true
    await get_tree().create_timer(1.2).timeout
    emit_signal("finished", true)
    emit_signal("microjuego_superado")


func derrota():
    if terminado:
        return
    terminado = true

    texto.text = "¡Se escapó!"
    texto.visible = true
    await get_tree().create_timer(1.2).timeout
    emit_signal("finished", false)
    emit_signal("microjuego_fallado")
