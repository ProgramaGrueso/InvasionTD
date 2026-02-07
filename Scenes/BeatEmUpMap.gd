extends Node2D

## Script para mapa Beat'em Up 2.5D en 2D
## Maneja el sorting de personajes según posición Y

# Límites del mapa (en píxeles)
const MAP_BOUNDS = {
	"min_x": 64.0,
	"max_x": 1536.0,
	"min_y": 64.0,
	"max_y": 536.0
}

# Grupo de personajes para sorting
var characters = []

func _ready():
	print("Mapa Beat'em Up 2D cargado")
	print("Límites del mapa: ", MAP_BOUNDS)
	print("Resolución: 1600x600")

func _process(delta):
	# Actualizar sorting de personajes cada frame
	update_character_sorting()

func register_character(character_node):
	"""Registra un personaje para el sistema de sorting"""
	if not character_node in characters:
		characters.append(character_node)

func unregister_character(character_node):
	"""Desregistra un personaje del sistema"""
	characters.erase(character_node)

func update_character_sorting():
	"""Ordena los personajes según su posición Y para superposición correcta"""
	# En 2.5D, los objetos más arriba (menor Y) se dibujan primero
	# Los objetos más abajo (mayor Y) se dibujan encima
	for character in characters:
		if character and is_instance_valid(character):
			# Usar posición Y como z_index
			character.z_index = int(character.global_position.y)

func get_spawn_point(point_name: String) -> Vector2:
	"""Obtiene la posición de un spawn point por nombre"""
	var spawn_node = get_node_or_null("PlayerSpawnPoints/" + point_name)
	if spawn_node:
		return spawn_node.global_position
	return Vector2.ZERO

func get_random_enemy_spawn() -> Vector2:
	"""Retorna un punto de spawn aleatorio para enemigos"""
	var spawn_points = $EnemySpawnPoints.get_children()
	if spawn_points.size() > 0:
		return spawn_points[randi() % spawn_points.size()].global_position
	return Vector2.ZERO

func is_within_bounds(position: Vector2) -> bool:
	"""Verifica si una posición está dentro de los límites del mapa"""
	return (position.x >= MAP_BOUNDS.min_x and position.x <= MAP_BOUNDS.max_x and
			position.y >= MAP_BOUNDS.min_y and position.y <= MAP_BOUNDS.max_y)

func clamp_to_bounds(position: Vector2) -> Vector2:
	"""Limita una posición a los límites del mapa"""
	var clamped = position
	clamped.x = clamp(position.x, MAP_BOUNDS.min_x, MAP_BOUNDS.max_x)
	clamped.y = clamp(position.y, MAP_BOUNDS.min_y, MAP_BOUNDS.max_y)
	return clamped
