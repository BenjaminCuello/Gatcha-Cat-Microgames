extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado

var lado_actual := ""  # izquierda o derecha
var esperando := false
var duracion_juego := 5.0
var juego_activo := true

func _ready():
    randomize()
    juego_activo = true
    ocultar_todos()
    $GatoEquilibrio.visible = true

    $LabelControles.visible = true
    $LabelInstruccion.text = "¡Atento!"
    $LabelInstruccion.visible = true
    await get_tree().create_timer(1.0).timeout
    $LabelInstruccion.visible = false

    # Elegir duración aleatoria del juego
    duracion_juego = [5.0, 6.0, 7.0].pick_random()

    $BarraTiempo.max_value = duracion_juego
    $BarraTiempo.value = duracion_juego
    $BarraTiempo.visible = true

    $TimerJuego.wait_time = duracion_juego
    $TimerJuego.start()

    nueva_instruccion()

func nueva_instruccion():
    if not juego_activo:
        return
    if esperando:
        perder()
        return

    # ❗ Evitar nueva flecha si queda poco tiempo
    if $TimerJuego.time_left <= 0.5:
        return

    lado_actual = ["izquierda", "derecha"].pick_random()
    esperando = true
    ocultar_todos()

    if lado_actual == "izquierda":
        $gato_izq.visible = true
        $LabelDireccion.text = "[→]"
    else:
        $gato_der.visible = true
        $LabelDireccion.text = "[←]"

    $LabelDireccion.visible = true
    $TimerRespuesta.start()

func _input(event):
    if not esperando:
        return

    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            return

        if lado_actual == "izquierda" and event.keycode == KEY_RIGHT:
            acertar()
        elif lado_actual == "derecha" and event.keycode == KEY_LEFT:
            acertar()
        else:
            perder()

func acertar():
    esperando = false
    $TimerRespuesta.stop()
    ocultar_todos()
    $GatoEquilibrio.visible = true
    $TimerCambio.start()

func perder():
    esperando = false
    juego_activo = false
    $TimerJuego.stop()
    $TimerRespuesta.stop()
    $TimerCambio.stop()
    ocultar_todos()
    $gato_se_cae.visible = true
    $LabelInstruccion.text = "¡Perdiste!"
    $LabelInstruccion.visible = true
    await get_tree().create_timer(1.0).timeout
    emit_signal("finished", false)

func victoria():
    juego_activo = false
    ocultar_todos()
    $LabelInstruccion.text = "¡Mantuviste el equilibrio!"
    $LabelInstruccion.visible = true
    await get_tree().create_timer(1.0).timeout
    emit_signal("finished", true)

func _on_TimerRespuesta_timeout():
    if esperando:
        perder()
        emit_signal("microjuego_fallado")


func _on_TimerCambio_timeout():
    nueva_instruccion()

func _on_TimerJuego_timeout():
    if esperando:
        perder()
        emit_signal("microjuego_fallado")

    else:
        victoria()
        emit_signal("microjuego_superado")


func _process(delta):
    if $TimerJuego.time_left > 0:
        $BarraTiempo.value = $TimerJuego.time_left

func ocultar_todos():
    $GatoEquilibrio.visible = false
    $gato_izq.visible = false
    $gato_der.visible = false
    $gato_se_cae.visible = false
    $LabelInstruccion.visible = false
    $LabelDireccion.visible = false
