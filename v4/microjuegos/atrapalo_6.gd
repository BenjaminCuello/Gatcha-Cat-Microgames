extends Control
signal finished(success)

var atrapado := false
var terminado := false

@onready var raton = $Raton
@onready var texto = $TextoInstruccion
@onready var timer = $TimerJuego
@onready var zona_captura = $ZonaCaptura

func _ready():
	atrapado = false
	terminado = false
	texto.text = "Atr[A]palo!"
	raton.position = Vector2(-100, 300)
	mover_raton()
	timer.start()

func mover_raton():
	var destino = Vector2(1200, 300)
	var tween = create_tween()
	tween.tween_property(raton, "position", destino, 3.0).set_trans(Tween.TRANS_LINEAR)

func _input(event):
	if atrapado or terminado:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return  # Ignorar ESC sin afectar la lógica

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
	await get_tree().create_timer(1.2).timeout
	emit_signal("finished", true)

func derrota():
	if terminado:
		return
	terminado = true
	texto.text = "¡Se escapó!"
	await get_tree().create_timer(1.2).timeout
	emit_signal("finished", false)
