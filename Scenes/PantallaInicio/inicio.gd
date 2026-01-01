extends Control

@onready var label_continuar = $Label2 # Asegúrate de que el nombre coincida en tu escena

func _ready():
	# Animación de parpadeo para el texto "Presiona Espacio"
	var tween = create_tween().set_loops()
	tween.tween_property(label_continuar, "modulate:a", 0.0, 0.6)
	tween.tween_property(label_continuar, "modulate:a", 1.0, 0.6)

func _process(_delta):
	# Detectar la tecla Espacio o Enter
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		print("¡Cambiando a escena de selección!") # Verás esto en la consola
		ir_a_seleccion()

func ir_a_seleccion():
	get_tree().change_scene_to_file("res://CharacterSelect/character_selection.tscn") 
