extends CanvasLayer

func _ready():
    hide()

func _on_BotonContinuar_pressed():
    get_tree().paused = false
    hide()

func _on_BotonMenu_pressed():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

func _on_BotonSalir_pressed():
    get_tree().quit()
