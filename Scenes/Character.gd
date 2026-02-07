extends CharacterBody2D

## Plantilla de personaje 2D para Beat'em Up 2.5D
## Coloca este script en tu personaje

# Velocidad de movimiento
@export var speed = 200.0
@export var is_player = true

# Referencia al mapa
var map

func _ready():
	# IMPORTANTE: Configurar capas de colisión
	collision_layer = 1
	collision_mask = 1
	
	# Registrar en el sistema de sorting del mapa
	map = get_tree().get_first_node_in_group("map")
	if map and map.has_method("register_character"):
		map.register_character(self)
	
	# El z_index se actualiza automáticamente según posición Y
	z_as_relative = false

func _exit_tree():
	# Desregistrar al salir
	if map and map.has_method("unregister_character"):
		map.unregister_character(self)

func _physics_process(delta):
	if is_player:
		handle_player_input(delta)
	else:
		handle_ai(delta)
	
	# Aplicar movimiento con colisiones
	move_and_slide()
	
	# Mantener dentro de los límites
	if map and map.has_method("clamp_to_bounds"):
		global_position = map.clamp_to_bounds(global_position)

func handle_player_input(delta):
	# Movimiento en 4 direcciones
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Aplicar velocidad
	velocity = input_dir * speed
	
	# Voltear sprite según dirección (opcional)
	if input_dir.x != 0 and has_node("Sprite2D"):
		$Sprite2D.flip_h = input_dir.x < 0

func handle_ai(delta):
	# Aquí va la lógica de IA de enemigos
	pass
