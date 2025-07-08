extends Control

signal continuar

func _ready():
	await get_tree().create_timer(2.5).timeout
	emit_signal("continuar")
	queue_free()
