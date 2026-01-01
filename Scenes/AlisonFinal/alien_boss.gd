extends CharacterBody2D
class_name AlienBoss

# -------------------------------------------------
# 1️⃣ CONFIGURABLES
# -------------------------------------------------
@export var player_path     : NodePath
@export var animated_sprite : AnimatedSprite2D

@export_group("Estadísticas Base")
@export var max_health      : float = 1000.0
@export var base_speed      : float = 120.0
@export var base_damage     : float = 10.0

# Variables internas
var health         : float
var current_phase  : int = 1
var speed          : float
var damage         : float
var player         : CharacterBody2D

# -------------------------------------------------
# 2️⃣ ON READY
# -------------------------------------------------
func _ready() -> void:
	# Es vital que el boss esté en este grupo para que Alison lo detecte
	add_to_group("enemies") 
	health = max_health
	
	# Intentar encontrar al player por la ruta o por grupo
	player = get_node_or_null(player_path)
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	_update_phase_stats()
	
	if animated_sprite:
		animated_sprite.play("idle")

# -------------------------------------------------
# 3️⃣ MOVIMIENTO / IA
# -------------------------------------------------
func _physics_process(_delta: float) -> void:
	if not player: 
		return

	var distance  = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)

	# El Boss persigue al jugador si está lejos
	if distance > 30.0: 
		velocity = direction * speed
		if animated_sprite:
			animated_sprite.play("walk")
			# Voltear sprite según dirección
			animated_sprite.flip_h = direction.x < 0
	else:
		# Si está muy cerca, se detiene
		velocity = Vector2.ZERO
		if animated_sprite:
			animated_sprite.play("idle")

	move_and_slide()

# -------------------------------------------------
# 4️⃣ SISTEMA DE DAÑO Y FASES
# -------------------------------------------------
func take_damage(amount: float) -> void:
	health -= amount
	print("Boss recibió daño. HP restante: ", health)

	# Actualizar UI si existe un nodo "main" con esa función
	var main = get_tree().get_first_node_in_group("main")
	if main and main.has_method("update_boss_health"):
		main.update_boss_health(health)

	if health <= 0:
		die()
	else:
		check_transformation()

func check_transformation() -> void:
	var percentage = (health / max_health) * 100.0
	var new_phase = 1
	
	# Lógica de fases basada en porcentaje de vida
	if percentage <= 15:
		new_phase = 3
	elif percentage <= 50:
		new_phase = 2
	else:
		new_phase = 1
		
	if new_phase != current_phase:
		current_phase = new_phase
		_transform_visuals()
		_update_phase_stats()

func _update_phase_stats() -> void:
	match current_phase:
		1:
			speed  = base_speed
			damage = base_damage
			modulate = Color.WHITE
		2:
			speed  = base_speed * 1.6
			damage = base_damage * 2.0
			modulate = Color(1, 0.8, 0.4) # Tono amarillento (enojado)
		3:
			speed  = base_speed * 2.5
			damage = 999 # Fase letal
			modulate = Color(1, 0.3, 0.3) # Tono rojizo (furia)

func _transform_visuals() -> void:
	# Efecto de escala rápido para indicar cambio de fase
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	print("¡BOSS ENTRÓ A FASE ", current_phase, "!")

# -------------------------------------------------
# 5️⃣ CONTACTO Y MUERTE
# -------------------------------------------------
# Esta función se llama si tienes un Area2D conectada para que el Boss dañe al tocar
func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func die() -> void:
	print("Boss derrotado")
	queue_free()
