extends Node

signal game_over(ganador, es_empate)

var vidas := 3
var microjuegos_completados := 0
var total_microjuegos := 0
var terminado := false
var tiempo_final := 0
var tiempo_oponente := 0
var nombre_oponente := ""
var match_id := ""
var oponente := ""

# Llama esto cuando pierdes una vida y llegas a 0
func perder_vida():
	vidas -= 1
	if vidas <= 0 and not terminado:
		terminado = true
		notificar_perdida_local(Global.username)
		rpc("notificar_perdida_remote", Global.username)

# Llama esto cuando superas un microjuego
func registrar_microjuego_completado():
	microjuegos_completados += 1
	if microjuegos_completados >= total_microjuegos and not terminado:
		terminado = true
		tiempo_final = Time.get_ticks_msec()
		notificar_terminado_local(Global.username, tiempo_final)
		rpc("notificar_terminado_remote", Global.username, tiempo_final)

# Función local para notificar pérdida
func notificar_perdida_local(jugador):
	if terminado:
		return
	terminado = true
	var ganador = ""
	if jugador == Global.username:
		ganador = oponente
		emit_signal("game_over", ganador, false)
	else:
		ganador = Global.username
		emit_signal("game_over", ganador, false)

# Función local para notificar fin
func notificar_terminado_local(jugador, tiempo):
	if terminado:
		return
	if jugador == Global.username:
		tiempo_final = tiempo
	else:
		tiempo_oponente = tiempo
	if tiempo_final > 0 and tiempo_oponente > 0:
		terminado = true
		if abs(tiempo_final - tiempo_oponente) <= 100: # margen de 0.1s para empate
			emit_signal("game_over", "empate", true)
		elif tiempo_final < tiempo_oponente:
			emit_signal("game_over", Global.username, false)
		else:
			emit_signal("game_over", oponente, false)

# Función remota para recibir pérdida del otro jugador
@rpc
func notificar_perdida_remote(jugador):
	notificar_perdida_local(jugador)

# Función remota para recibir terminado del otro jugador
@rpc
func notificar_terminado_remote(jugador, tiempo):
	notificar_terminado_local(jugador, tiempo)

func reset():
	vidas = 3
	microjuegos_completados = 0
	terminado = false
	tiempo_final = 0
	tiempo_oponente = 0
