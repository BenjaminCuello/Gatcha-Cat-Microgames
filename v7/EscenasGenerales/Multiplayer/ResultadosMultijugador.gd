extends Control

var ganador := ""
var stats_text := ""
var vidas := 0
var es_empate := false

func mostrar_resultados(_ganador: String, _stats_text: String, _vidas: int, _es_empate := false):
	ganador = _ganador
	stats_text = _stats_text
	vidas = _vidas
	es_empate = _es_empate

func _ready():
	var label_ganador = $VBoxContainer/LabelGanador if has_node("VBoxContainer/LabelGanador") else null
	var label_stats = $VBoxContainer/LabelStats if has_node("VBoxContainer/LabelStats") else null
	var boton_salir = $VBoxContainer/BotonSalir if has_node("VBoxContainer/BotonSalir") else null
	var label_vidas = $VBoxContainer/LabelVidas if has_node("VBoxContainer/LabelVidas") else null

	if es_empate:
		if label_ganador:
			label_ganador.text = "¡Empate!"
		if label_stats:
			label_stats.text = stats_text
		if label_vidas:
			label_vidas.text = ""
	else:
		if ganador == Global.username:
			if label_ganador:
				label_ganador.text = "¡Ganaste!"
		elif ganador == "empate":
			if label_ganador:
				label_ganador.text = "¡Empate!"
		else:
			if label_ganador:
				label_ganador.text = "¡Perdiste!"
		if label_stats:
			label_stats.text = stats_text
		if label_vidas:
			label_vidas.text = "Vidas restantes: " + str(vidas)

	if boton_salir:
		boton_salir.pressed.connect(_on_BotonSalir_pressed)

func _on_BotonSalir_pressed():
	# Limpia la escena completamente y vuelve al menú principal
	for child in get_tree().root.get_children():
		if child != self:
			child.queue_free()
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
