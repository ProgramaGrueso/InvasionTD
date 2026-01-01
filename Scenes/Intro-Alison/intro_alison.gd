extends Control

@onready var video = $VideoPlayer

func _ready():
	# Conectamos la señal de cuando termina el video
	video.finished.connect(_on_video_finished)

func _process(_delta):
	# Si presiona espacio, saltamos al minijuego
	if Input.is_action_just_pressed("ui_accept"): # "ui_accept" suele ser Espacio/Enter
		ir_al_minijuego()

func _on_video_finished():
	ir_al_minijuego()

func ir_al_minijuego():
	get_tree().change_scene_to_file("res://Minijuego1.tscn")
