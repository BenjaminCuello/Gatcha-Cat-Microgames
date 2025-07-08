extends Control

# Referencias a los controles (usando get_node_or_null para evitar errores)
@onready var slider_volumen_master = get_node_or_null("VBoxContainer/ConfiguracionAudio/HBoxContainer/SliderVolumenMaster")
@onready var label_valor_master = get_node_or_null("VBoxContainer/ConfiguracionAudio/HBoxContainer/LabelValorMaster")
@onready var slider_volumen_musica = get_node_or_null("VBoxContainer/ConfiguracionAudio/HBoxContainer2/SliderVolumenMusica")
@onready var label_valor_musica = get_node_or_null("VBoxContainer/ConfiguracionAudio/HBoxContainer2/LabelValorMusica")
@onready var slider_volumen_sfx = get_node_or_null("VBoxContainer/ConfiguracionAudio/HBoxContainer3/SliderVolumenSFX")
@onready var label_valor_sfx = get_node_or_null("VBoxContainer/ConfiguracionAudio/HBoxContainer3/LabelValorSFX")

@onready var check_pantalla_completa = get_node_or_null("VBoxContainer/ConfiguracionVideo/HBoxContainer4/CheckPantallaCompleta")
@onready var check_vsync = get_node_or_null("VBoxContainer/ConfiguracionVideo/CheckVSync")
@onready var check_mostrar_fps = get_node_or_null("VBoxContainer/ConfiguracionJuego/CheckMostrarFPS")
@onready var option_dificultad = get_node_or_null("VBoxContainer/ConfiguracionJuego/OptionDificultad")

# Variables de configuración
var config_file = "user://opciones.cfg"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("=== VERIFICANDO NODOS ===")
	verificar_nodos()
	configurar_controles()
	cargar_configuracion()
	conectar_señales()

func verificar_nodos():
	print("Slider Master:", slider_volumen_master != null)
	print("Label Master:", label_valor_master != null)
	print("Slider Musica:", slider_volumen_musica != null)
	print("Label Musica:", label_valor_musica != null)
	print("Slider SFX:", slider_volumen_sfx != null)
	print("Label SFX:", label_valor_sfx != null)
	print("Check Pantalla:", check_pantalla_completa != null)
	print("Check VSync:", check_vsync != null)
	print("Check FPS:", check_mostrar_fps != null)
	print("Option Dificultad:", option_dificultad != null)
	
	# Mostrar estructura real de nodos
	print("=== ESTRUCTURA REAL ===")
	mostrar_estructura(self, 0)

func mostrar_estructura(nodo: Node, nivel: int):
	var indent = ""
	for i in range(nivel):
		indent += "  "
	print(indent + nodo.name + " (" + nodo.get_class() + ")")
	
	for child in nodo.get_children():
		mostrar_estructura(child, nivel + 1)

func configurar_controles():
	# Solo configurar si los nodos existen
	if slider_volumen_master:
		slider_volumen_master.min_value = 0.0
		slider_volumen_master.max_value = 1.0
		slider_volumen_master.step = 0.01
		slider_volumen_master.value = 1.0
	
	if slider_volumen_musica:
		slider_volumen_musica.min_value = 0.0
		slider_volumen_musica.max_value = 1.0
		slider_volumen_musica.step = 0.01
		slider_volumen_musica.value = 1.0
	
	if slider_volumen_sfx:
		slider_volumen_sfx.min_value = 0.0
		slider_volumen_sfx.max_value = 1.0
		slider_volumen_sfx.step = 0.01
		slider_volumen_sfx.value = 1.0
	
	if option_dificultad:
		option_dificultad.clear()
		option_dificultad.add_item("Muy Fácil")
		option_dificultad.add_item("Fácil")
		option_dificultad.add_item("Normal")
		option_dificultad.add_item("Difícil")
		option_dificultad.add_item("Muy Difícil")
		option_dificultad.selected = 2

	# Configurar labels solo si existen
	configurar_labels()

func configurar_labels():
	var titulo = get_node_or_null("VBoxContainer/TituloOpciones")
	if titulo: titulo.text = "OPCIONES"
	
	var label_master = get_node_or_null("VBoxContainer/ConfiguracionAudio/LabelVolumenMaster")
	if label_master: label_master.text = "Volumen Master:"
	
	var label_musica = get_node_or_null("VBoxContainer/ConfiguracionAudio/LabelVolumenMusica")
	if label_musica: label_musica.text = "Volumen Música:"
	
	var label_sfx = get_node_or_null("VBoxContainer/ConfiguracionAudio/LabelVolumenSFX")
	if label_sfx: label_sfx.text = "Volumen Efectos:"
	
	var label_pantalla = get_node_or_null("VBoxContainer/ConfiguracionVideo/LabelPantalla")
	if label_pantalla: label_pantalla.text = "Configuración de Pantalla:"
	
	var label_pantalla_completa = get_node_or_null("VBoxContainer/ConfiguracionVideo/LabelPantallaCompleta")
	if label_pantalla_completa: label_pantalla_completa.text = "Pantalla Completa"
	
	var label_vsync = get_node_or_null("VBoxContainer/ConfiguracionVideo/LabelVSync")
	if label_vsync: label_vsync.text = "Sincronización Vertical"
	
	var label_dificultad = get_node_or_null("VBoxContainer/ConfiguracionJuego/LabelDificultad")
	if label_dificultad: label_dificultad.text = "Dificultad por Defecto:"
	
	var label_fps = get_node_or_null("VBoxContainer/ConfiguracionJuego/LabelMostrarFPS")
	if label_fps: label_fps.text = "Mostrar FPS"
	
	# Configurar botones
	var boton_guardar = get_node_or_null("VBoxContainer/Botones/BotonGuardar")
	if boton_guardar: boton_guardar.text = "Guardar"
	
	var boton_restaurar = get_node_or_null("VBoxContainer/Botones/BotonRestaurar")
	if boton_restaurar: boton_restaurar.text = "Valores por Defecto"
	
	var boton_volver = get_node_or_null("VBoxContainer/Botones/BotonVolver")
	if boton_volver: boton_volver.text = "Volver al Menú"

func conectar_señales():
	# Solo conectar si los nodos existen
	if slider_volumen_master:
		slider_volumen_master.value_changed.connect(_on_volumen_master_changed)
	
	if slider_volumen_musica:
		slider_volumen_musica.value_changed.connect(_on_volumen_musica_changed)
	
	if slider_volumen_sfx:
		slider_volumen_sfx.value_changed.connect(_on_volumen_sfx_changed)
	
	if check_pantalla_completa:
		check_pantalla_completa.toggled.connect(_on_pantalla_completa_toggled)
	
	if check_vsync:
		check_vsync.toggled.connect(_on_vsync_toggled)
	
	if check_mostrar_fps:
		check_mostrar_fps.toggled.connect(_on_mostrar_fps_toggled)
	
	if option_dificultad:
		option_dificultad.item_selected.connect(_on_dificultad_selected)
	
	# Conectar botones
	var boton_guardar = get_node_or_null("VBoxContainer/Botones/BotonGuardar")
	if boton_guardar:
		boton_guardar.pressed.connect(_on_boton_guardar_pressed)
	
	var boton_restaurar = get_node_or_null("VBoxContainer/Botones/BotonRestaurar")
	if boton_restaurar:
		boton_restaurar.pressed.connect(_on_boton_restaurar_pressed)
	
	var boton_volver = get_node_or_null("VBoxContainer/Botones/BotonVolver")
	if boton_volver:
		boton_volver.pressed.connect(_on_boton_volver_pressed)

# Funciones de los sliders de volumen
func _on_volumen_master_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	if label_valor_master:
		label_valor_master.text = str(int(value * 100)) + "%"

func _on_volumen_musica_changed(value: float):
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	if label_valor_musica:
		label_valor_musica.text = str(int(value * 100)) + "%"

func _on_volumen_sfx_changed(value: float):
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	if label_valor_sfx:
		label_valor_sfx.text = str(int(value * 100)) + "%"

# Funciones de checkboxes
func _on_pantalla_completa_toggled(pressed: bool):
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(pressed: bool):
	if pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_mostrar_fps_toggled(pressed: bool):
	if has_node("/root/Global"):
		Global.mostrar_fps = pressed
	
	if pressed:
		mostrar_fps_display()
	else:
		ocultar_fps_display()

func _on_dificultad_selected(index: int):
	if has_node("/root/Global"):
		Global.dificultad_por_defecto = index + 1

# Funciones de botones
func _on_boton_guardar_pressed():
	guardar_configuracion()
	mostrar_mensaje("Configuración guardada")

func _on_boton_restaurar_pressed():
	restaurar_valores_por_defecto()
	mostrar_mensaje("Configuración restaurada")

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

# Sistema de guardado/carga
func guardar_configuracion():
	var config = ConfigFile.new()
	
	if slider_volumen_master:
		config.set_value("audio", "volumen_master", slider_volumen_master.value)
	if slider_volumen_musica:
		config.set_value("audio", "volumen_musica", slider_volumen_musica.value)
	if slider_volumen_sfx:
		config.set_value("audio", "volumen_sfx", slider_volumen_sfx.value)
	
	if check_pantalla_completa:
		config.set_value("video", "pantalla_completa", check_pantalla_completa.button_pressed)
	if check_vsync:
		config.set_value("video", "vsync", check_vsync.button_pressed)
	
	if option_dificultad:
		config.set_value("juego", "dificultad_por_defecto", option_dificultad.selected)
	if check_mostrar_fps:
		config.set_value("juego", "mostrar_fps", check_mostrar_fps.button_pressed)
	
	config.save(config_file)
	print("Configuración guardada en:", config_file)

func cargar_configuracion():
	var config = ConfigFile.new()
	var err = config.load(config_file)
	
	if err != OK:
		print("No se pudo cargar la configuración, usando valores por defecto")
		return
	
	if slider_volumen_master:
		slider_volumen_master.value = config.get_value("audio", "volumen_master", 1.0)
	if slider_volumen_musica:
		slider_volumen_musica.value = config.get_value("audio", "volumen_musica", 1.0)
	if slider_volumen_sfx:
		slider_volumen_sfx.value = config.get_value("audio", "volumen_sfx", 1.0)
	
	if check_pantalla_completa:
		check_pantalla_completa.button_pressed = config.get_value("video", "pantalla_completa", false)
	if check_vsync:
		check_vsync.button_pressed = config.get_value("video", "vsync", true)
	
	if option_dificultad:
		option_dificultad.selected = config.get_value("juego", "dificultad_por_defecto", 2)
	if check_mostrar_fps:
		check_mostrar_fps.button_pressed = config.get_value("juego", "mostrar_fps", false)
	
	# Aplicar configuración cargada
	if slider_volumen_master:
		_on_volumen_master_changed(slider_volumen_master.value)
	if slider_volumen_musica:
		_on_volumen_musica_changed(slider_volumen_musica.value)
	if slider_volumen_sfx:
		_on_volumen_sfx_changed(slider_volumen_sfx.value)
	if check_pantalla_completa:
		_on_pantalla_completa_toggled(check_pantalla_completa.button_pressed)
	if check_vsync:
		_on_vsync_toggled(check_vsync.button_pressed)
	if check_mostrar_fps:
		_on_mostrar_fps_toggled(check_mostrar_fps.button_pressed)
	if option_dificultad:
		_on_dificultad_selected(option_dificultad.selected)

func restaurar_valores_por_defecto():
	if slider_volumen_master:
		slider_volumen_master.value = 1.0
		_on_volumen_master_changed(1.0)
	if slider_volumen_musica:
		slider_volumen_musica.value = 1.0
		_on_volumen_musica_changed(1.0)
	if slider_volumen_sfx:
		slider_volumen_sfx.value = 1.0
		_on_volumen_sfx_changed(1.0)
	if check_pantalla_completa:
		check_pantalla_completa.button_pressed = false
		_on_pantalla_completa_toggled(false)
	if check_vsync:
		check_vsync.button_pressed = true
		_on_vsync_toggled(true)
	if option_dificultad:
		option_dificultad.selected = 2
		_on_dificultad_selected(2)
	if check_mostrar_fps:
		check_mostrar_fps.button_pressed = false
		_on_mostrar_fps_toggled(false)

func mostrar_mensaje(texto: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = texto
	add_child(dialog)
	dialog.popup_centered()
	
	await get_tree().create_timer(2.0).timeout
	if dialog and is_instance_valid(dialog):
		dialog.queue_free()

func mostrar_fps_display():
	if not has_node("FPSDisplay"):
		var fps_label = Label.new()
		fps_label.name = "FPSDisplay"
		fps_label.text = "FPS: 60"
		fps_label.position = Vector2(10, 10)
		fps_label.add_theme_color_override("font_color", Color.WHITE)
		fps_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		fps_label.add_theme_constant_override("shadow_offset_x", 2)
		fps_label.add_theme_constant_override("shadow_offset_y", 2)
		add_child(fps_label)

func ocultar_fps_display():
	if has_node("FPSDisplay"):
		$FPSDisplay.queue_free()

func _process(delta):
	if check_mostrar_fps and check_mostrar_fps.button_pressed and has_node("FPSDisplay"):
		$FPSDisplay.text = "FPS: " + str(Engine.get_frames_per_second())
