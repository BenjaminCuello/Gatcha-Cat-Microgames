extends Node2D
signal microjuego_superado
signal microjuego_fallado
signal finished(success)

@onready var cat = $pataGato/CollisionShape2D
@onready var mouse = $SpriteRaton
@onready var jugando = true
@export var duracion_juego = 5.0


func _process(delta):
    
    if Input.is_key_pressed(KEY_ESCAPE):
        return  # Ignora ESC

    #print("a")
    if Input.is_key_pressed(KEY_SPACE) and jugando == true:
        agarrarRaton()
        
    if $TiempoRestante.time_left >= 0:
        $barraDeTiempo.value = $TiempoRestante.time_left

func _ready():
    randomize()
    duracion_juego = [2.0, 3.0, 5.0].pick_random()


    await get_tree().create_timer(0.05).timeout
    #por alguna razón si no te mueves por una partida entera, la siguiente vez que jueges
    #la pata de gato desaparece, por lo que esto es para ponerla en su lugar (no funciona sin el timer)
    $pataGato.position = Vector2(0, 0)
    await get_tree().create_timer(1.0).timeout

    $SpriteRaton/AnimationPlayer.play("RESET")
    $Instruccion.visible = false

    $barraDeTiempo.max_value = duracion_juego
    $barraDeTiempo.value = duracion_juego

    $TiempoRestante.start(duracion_juego)


func agarrarRaton():
    var distancia = cat.global_position.distance_to(mouse.global_position)
    var radioAtrapar = 120
    #print("Distancia entre gato y ratón: ", distancia)

    if distancia <= radioAtrapar:
        $Instruccion.text = "¡Lo atrapaste!"
        $Instruccion.visible = true
        print("¡Lo atrapaste!")
        emit_signal("finished", true)
        jugando = false
        $TiempoRestante.stop()
        emit_signal("microjuego_superado")

    else:
        print("No le diste")
        emit_signal("microjuego_fallado")


func _on_timer_timeout():
    jugando = false
    emit_signal("finished", false)
    print("juego terminado por tiempo, perdiste")
    emit_signal("microjuego_fallado")
