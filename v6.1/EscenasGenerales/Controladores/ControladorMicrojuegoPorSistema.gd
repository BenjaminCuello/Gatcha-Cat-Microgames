extends Node

# Esta variable se define desde fuera antes de cargar la escena
var escena_microjuego: PackedScene
var instancia_microjuego

func _ready():
    if escena_microjuego:
        instancia_microjuego = escena_microjuego.instantiate()
        add_child(instancia_microjuego)

        if instancia_microjuego.has_signal("finished"):
            instancia_microjuego.connect("finished", Callable(self, "_on_microjuego_finished"))
        else:
            print("❌ El microjuego no tiene señal 'finished'")

func _on_microjuego_finished(success: bool) -> void:
    if not success:
        Juego.vidas -= 1
        print("💥 Perdiste una vida. Vidas restantes:", Juego.vidas)

    await get_tree().create_timer(1.0).timeout
    get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/MicroInicioContadorVidas.tscn")
