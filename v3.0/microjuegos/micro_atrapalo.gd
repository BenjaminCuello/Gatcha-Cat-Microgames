extends Control

var atrapado = false

@onready var raton = $Raton
@onready var texto = $TextoInstruccion
@onready var timer = $TimerJuego
@onready var zona_captura = $ZonaCaptura  # si decides usarla


func _ready():
	texto.text = "¡Presiona A cuando el ratón pase!"
	raton.position = Vector2(-100, 300)  # Comienza fuera de pantalla
	mover_raton()
	set_process_input(true)


func mover_raton():
	var destino = Vector2(1200, 300)  # ajusta según tu layout
	var tween = create_tween()
	tween.tween_property(raton, "position", destino, 3.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _input(event):
	if event.is_action_pressed("ui_accept") and !atrapado:
		if raton.get_global_rect().intersects(zona_captura.get_global_rect()):
			atrapado = true
			victoria()


func _on_TimerJuego_timeout():
	if not atrapado:
		derrota()

func victoria():
	texto.text = "¡Lo atrapaste!"
	raton.modulate = Color(0, 1, 0)  # verde como feedback
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://escenas/fin_victoria.tscn")
	emit_signal("finished", true)

func derrota():
	texto.text = "¡Se escapó!"
	raton.modulate = Color(1, 0, 0)  # rojo como feedback
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://escenas/fin_derrota.tscn")
	emit_signal("finished", false)


func _on_Timer_timeout() -> void:
	pass # Replace with function body.
