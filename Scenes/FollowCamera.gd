extends Camera2D

## Cámara 2D que sigue al jugador en beat'em up 2.5D

# Referencia al jugador
@export var target: Node2D = null
@export var follow_smoothing = 5.0

# Límites de la cámara (para que no salga del mapa)
@export var enable_bounds = true
@export var min_x = 576.0  # Mitad del ancho de pantalla (1152/2)
@export var max_x = 1024.0  # Ancho mapa - mitad pantalla (1600-576)
@export var min_y = 300.0  # Mitad del alto de pantalla (600/2)
@export var max_y = 300.0  # Alto mapa - mitad pantalla (600-300)

func _ready():
	# Si no se asignó target manualmente, buscar el jugador
	if target == null:
		# Buscar nodo con nombre "Player" o en grupo "player"
		target = get_tree().get_first_node_in_group("player")
		if target == null:
			# Buscar cualquier nodo llamado "Player"
			target = get_node_or_null("/root/BeatEmUpMap/Player")
	
	if target == null:
		push_warning("Camera2D: No se encontró jugador. Asigna el target manualmente.")

func _process(delta):
	if target == null:
		return
	
	# Calcular posición deseada
	var desired_position = target.global_position
	
	# Aplicar límites si están activos
	if enable_bounds:
		desired_position.x = clamp(desired_position.x, min_x, max_x)
		desired_position.y = clamp(desired_position.y, min_y, max_y)
	
	# Suavizar el movimiento
	global_position = global_position.lerp(desired_position, follow_smoothing * delta)
