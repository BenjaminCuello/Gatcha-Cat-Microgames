extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado

var teclas = []
var teclas_mostradas = []
var index_actual := 0
var esperando_input := false

@onready var texto = $TextoInstruccion
@onready var controles = $TextoControles

func _ready():
    ocultar_todos()

    $GatoQuieto.visible = true
    $Sombrero.visible = true

    texto.text = "¡Prepárate!"
    texto.visible = true
    controles.visible = false

    $BarraTiempo.max_value = 6.0
    $BarraTiempo.value = 6.0
    $BarraTiempo.visible = true
    $TimerBarra.start()

    # Esperar 1 segundo y ocultar instrucción
    await get_tree().create_timer(1.0).timeout
    texto.visible = false
    $TimerApertura.start()

    # Letras y números
    for i in range(65, 91): teclas.append(String.chr(i))
    for i in range(48, 58): teclas.append(String.chr(i))

    teclas.shuffle()
    teclas_mostradas = teclas.slice(0, 3)

func _on_TimerApertura_timeout():
    mostrar_tecla()

func mostrar_tecla():
    if index_actual >= 3:
        victoria()
        return

    esperando_input = true
    var tecla = teclas_mostradas[index_actual]
    controles.text = "Presiona:\n[" + tecla + "]"
    controles.visible = true

    var tiempos = [0.8, 1.0, 1.2]
    $TimerRespuesta.start(tiempos.pick_random())

func _input(event):
    if not esperando_input:
        return

    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            return

        var presionada = event.as_text().to_upper()
        var esperada = teclas_mostradas[index_actual]

        if presionada == esperada:
            acierto()
        else:
            derrota()

func acierto():
    esperando_input = false
    $TimerRespuesta.stop()
    controles.visible = false

    match index_actual:
        0:
            $GatoQuieto.visible = false
            $Pose1.visible = true
        1:
            $Pose1.visible = false
            $Pose2.visible = true
        2:
            $Pose2.visible = false
            $Pose3.visible = true
            await get_tree().create_timer(0.5).timeout
            victoria()

            return

    index_actual += 1
    mostrar_tecla()

func derrota():
    if esperando_input:
        esperando_input = false
        $TimerRespuesta.stop()
        $TimerBarra.stop()

        ocultar_poses()
        $GatoTriste.visible = true
        texto.text = "¡Fallaste!"
        texto.visible = true
        controles.visible = false

        await get_tree().create_timer(1.0).timeout
        emit_signal("microjuego_fallado")

        emit_signal("finished", false)

func victoria():
    $TimerBarra.stop()
    ocultar_todos()
    $GatoFeliz.visible = true
    $SombreroDinero.visible = true
    $PersonasFelices1.visible = true
    $PersonasFelices2.visible = true
    texto.text = "¡Genial!"
    texto.visible = true
    await get_tree().create_timer(1.2).timeout
    emit_signal("microjuego_superado")

    emit_signal("finished", true)

func _on_TimerRespuesta_timeout():
    derrota()
    emit_signal("microjuego_fallado")


func _on_TimerBarra_timeout():
    derrota()
    emit_signal("microjuego_fallado")


func _process(delta):
    if $TimerBarra.time_left > 0:
        $BarraTiempo.value = $TimerBarra.time_left

func ocultar_poses():
    $GatoQuieto.visible = false
    $Pose1.visible = false
    $Pose2.visible = false
    $Pose3.visible = false

func ocultar_todos():
    ocultar_poses()
    $GatoFeliz.visible = false
    $GatoTriste.visible = false
    $Sombrero.visible = false
    $SombreroDinero.visible = false
    $PersonasFelices1.visible = false
    $PersonasFelices2.visible = false
    texto.visible = false
    controles.visible = false
