extends Control

@onready var resultado_winner = $VBoxContainer/winner
@onready var ganador_label = $VBoxContainer/winnername


var ganador: String = ""
var victoria: bool = true

func _ready():
	if victoria:
		resultado_winner.text = "¡Ganaste! 🎉"
	else:
		resultado_winner.text = "¡Perdiste! 😿"

	ganador_label.text = "Ganador: %s" % ganador

func _on_Button_pressed():
	get_tree().change_scene_to_file("res://EscenasGenerales/MenuPrincipal.tscn")
