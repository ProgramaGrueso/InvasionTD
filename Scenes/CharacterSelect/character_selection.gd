extends Control

# Asegúrate de que estos nombres coincidan con tu árbol de nodos
@onready var alisson_ui = $VBoxContainer 
@onready var juancho_ui = $VBoxContainer2
@onready var label_instruccion = $Label2 

var seleccion = 0 # 0 para Alisson, 1 para Juancho

func _ready():
	# --- AJUSTE FORZADO POR CÓDIGO ---
	# Usamos 'top_level' para que el contenedor NO bloquee la posición ni la escala
	alisson_ui.top_level = true
	juancho_ui.top_level = true
	
	# Resetear escala a 1 para evitar que se vean gigantes o desaparezcan
	alisson_ui.scale = Vector2(1, 1)
	juancho_ui.scale = Vector2(1, 1)
	
	# Configuramos posiciones (X, Y) y tamaños
	ajustar_contenedor(alisson_ui, Vector2(250, 200)) 
	ajustar_contenedor(juancho_ui, Vector2(750, 200))
	
	actualizar_visual()

func ajustar_contenedor(nodo, pos):
	# Posición manual forzada
	nodo.position = pos
	nodo.custom_minimum_size = Vector2(300, 300)
	
	# Forzar que la imagen interna se encoja correctamente
	var imagen = nodo.get_node("TextureRect")
	if imagen:
		imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE #
		imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED #
		imagen.custom_minimum_size = Vector2(250, 250)

func _process(_delta):
	if Input.is_action_just_pressed("ui_right") and seleccion == 0:
		seleccion = 1
		actualizar_visual()
	
	if Input.is_action_just_pressed("ui_left") and seleccion == 1:
		seleccion = 0
		actualizar_visual()

	if Input.is_action_just_pressed("ui_accept"):
		confirmar_seleccion()

func actualizar_visual():
	# Tu lógica de color y escala se mantiene, ahora sí funcionará
	if seleccion == 0:
		alisson_ui.modulate = Color(1, 1, 1)
		alisson_ui.scale = Vector2(1.1, 1.1) # Un poco de zoom al elegido
		alisson_ui.z_index = 1
		
		juancho_ui.modulate = Color(0.4, 0.4, 0.4) # Más oscuro
		juancho_ui.scale = Vector2(1.0, 1.0)
		juancho_ui.z_index = 0
	else:
		juancho_ui.modulate = Color(1, 1, 1)
		juancho_ui.scale = Vector2(1.1, 1.1)
		juancho_ui.z_index = 1
		
		alisson_ui.modulate = Color(0.4, 0.4, 0.4)
		alisson_ui.scale = Vector2(1.0, 1.0)
		alisson_ui.z_index = 0

func confirmar_seleccion():
	var nombre_personaje = "Alisson" if seleccion == 0 else "Juancho"
	print("Elegido: ", nombre_personaje)
	
	# Efecto visual de brillo
	var tween = create_tween()
	var nodo_elegido = alisson_ui if seleccion == 0 else juancho_ui
	tween.tween_property(nodo_elegido, "modulate", Color(2, 2, 2), 0.1)
	tween.tween_property(nodo_elegido, "modulate", Color(1, 1, 1), 0.1)
	
	await get_tree().create_timer(0.5).timeout
	
	# LÓGICA DE TRANSICIÓN CON EL NOMBRE CORRECTO
	if seleccion == 0:
		# Verifica que el nombre sea exactamente igual al de tu archivo
		get_tree().change_scene_to_file("res://Intro-Alison/intro-alison.tscn")
	else:
		# Aquí asegúrate de que el nombre del nivel también sea correcto
		get_tree().change_scene_to_file("res://Minijuego1.tscn")
