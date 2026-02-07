extends CharacterBody2D
class_name Player

# -------------------------------------------------
# 1️⃣ CONFIGURACIÓN
# -------------------------------------------------
@export var speed := 250.0
@export var damage_punch := 20.0
@export var damage_finisher := 60.0

# SALUD
@export var max_health := 100.0
var health : float
var is_dead := false

# INVULNERABILIDAD
var is_invulnerable := false
var invulnerability_duration := 1.5
var invulnerability_timer := 0.0
var flash_timer := 0.0

# DASH
@export var dash_speed := 700.0
@export var dash_duration := 0.15
@export var dash_cooldown := 0.5

# COMBOS Y PUNTUACIÓN
const COMBO_WINDOW := 0.5
var combo_step := 0
var combo_timer := 0.0
var is_attacking_flag := false
var last_direction := 1
var combo_count := 0
var total_hits := 0
var score := 0

# DASH STATE
var is_dashing := false
var dash_timer := 0.0
var dash_cd_timer := 0.0

# REFERENCIAS
@onready var sprite = $AnimatedSprite2D
@onready var pivot = $HitboxPivot
@onready var hitbox_area = $HitboxPivot/Hitbox
@onready var attack_area_shape = $HitboxPivot/Hitbox/CollisionShape2D
@onready var hurtbox = $HurtBox

# 🆕 COMPATIBILIDAD CON MAPA BEAT'EM UP
var map

# SEÑALES
signal health_changed(current_health, max_health)
signal score_changed(new_score)
signal combo_changed(combo_count)
signal player_died

# -------------------------------------------------
# 2️⃣ READY
# -------------------------------------------------
func _ready():
	add_to_group("player")
	health = max_health
	sprite.animation_finished.connect(_on_animation_finished)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	apply_transparent_shader()

	if attack_area_shape:
		attack_area_shape.disabled = true
	
	health_changed.emit(health, max_health)
	
	# 🆕 CONFIGURAR COLISIONES PARA EL MAPA
	collision_layer = 1
	collision_mask = 1
	
	# 🆕 REGISTRAR EN EL SISTEMA DE SORTING DEL MAPA
	map = get_tree().get_first_node_in_group("map")
	if map and map.has_method("register_character"):
		map.register_character(self)

# -------------------------------------------------
# 3️⃣ SHADER (TRANSPARENCIA DE BLANCOS)
# -------------------------------------------------
func apply_transparent_shader():
	var shader_code := """
shader_type canvas_item;
void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.r > 0.85 && color.g > 0.85 && color.b > 0.85) {
		color.a = 0.0;
	}
	COLOR = color;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = shader_code
	sprite.material = mat

# -------------------------------------------------
# 4️⃣ PHYSICS PROCESS
# -------------------------------------------------
func _physics_process(delta):
	if is_dead:
		return
	
	# Invulnerabilidad timer
	if is_invulnerable:
		invulnerability_timer -= delta
		flash_timer += delta * 10.0
		
		# Efecto de parpadeo
		if int(flash_timer) % 2 == 0:
			modulate.a = 0.3
		else:
			modulate.a = 1.0
		
		if invulnerability_timer <= 0:
			is_invulnerable = false
			modulate.a = 1.0
			flash_timer = 0.0
	
	# Combo timer
	if combo_timer > 0:
		combo_timer -= delta
	else:
		if combo_step > 0:
			combo_step = 0
			if combo_count > 1:
				combo_count = 0
				combo_changed.emit(combo_count)
	
	# Dash cooldown
	if dash_cd_timer > 0:
		dash_cd_timer -= delta

	# DASH (SHIFT)
	if Input.is_key_pressed(KEY_SHIFT) and not is_dashing and dash_cd_timer <= 0:
		start_dash()

	# Mientras dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		
		# 🆕 MANTENER DENTRO DE LOS LÍMITES DEL MAPA
		if map and map.has_method("clamp_to_bounds"):
			global_position = map.clamp_to_bounds(global_position)
		return

	# ATAQUE (Z)
	if Input.is_key_pressed(KEY_Z) and not is_attacking_flag:
		perform_attack()
		return

	# MOVIMIENTO NORMAL
	if not is_attacking_flag and not is_invulnerable:
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_dir != Vector2.ZERO:
			velocity = input_dir * speed
			if input_dir.x != 0:
				last_direction = sign(input_dir.x)
			sprite.play("walk")
			actualizar_orientacion("walk")
		else:
			velocity = velocity.move_toward(Vector2.ZERO, speed)
			if velocity.length() < 10:
				velocity = Vector2.ZERO
				sprite.play("idle")
				actualizar_orientacion("idle")

	move_and_slide()
	
	# 🆕 MANTENER DENTRO DE LOS LÍMITES DEL MAPA
	if map and map.has_method("clamp_to_bounds"):
		global_position = map.clamp_to_bounds(global_position)

# -------------------------------------------------
# 5️⃣ DASH
# -------------------------------------------------
func start_dash():
	is_dashing = true
	is_attacking_flag = false
	dash_timer = dash_duration
	dash_cd_timer = dash_cooldown

	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		dir = Vector2(last_direction, 0)

	velocity = dir.normalized() * dash_speed

# -------------------------------------------------
# 6️⃣ ATAQUES
# -------------------------------------------------
func perform_attack():
	if is_dashing:
		return

	is_attacking_flag = true
	velocity = Vector2.ZERO
	combo_timer = COMBO_WINDOW

	var anim := ""
	if combo_step == 0:
		anim = "punch_1"
		combo_step = 1
	elif combo_step == 1:
		anim = "punch_2"
		combo_step = 2
	else:
		anim = "finisher"
		combo_step = 0

	sprite.play(anim)
	actualizar_orientacion(anim)

	attack_area_shape.disabled = false
	await get_tree().physics_frame
	_check_hit()
	attack_area_shape.disabled = true

	# Liberación segura
	await get_tree().create_timer(0.15).timeout
	is_attacking_flag = false

func _check_hit():
	var targets = hitbox_area.get_overlapping_bodies()
	for target in targets:
		if target.is_in_group("enemies") and target.has_method("take_damage"):
			var dmg = damage_finisher if combo_step == 2 else damage_punch
			target.take_damage(dmg)
			
			total_hits += 1
			combo_count += 1
			combo_changed.emit(combo_count)
			
			# Sistema de puntuación
			var base_score = int(dmg)
			var combo_bonus = combo_count * 10
			var points = base_score + combo_bonus
			score += points
			score_changed.emit(score)
			
			# Reiniciar combo timer
			combo_timer = COMBO_WINDOW

# -------------------------------------------------
# 7️⃣ ORIENTACIÓN
# -------------------------------------------------
func actualizar_orientacion(anim):
	if last_direction == 1:
		pivot.scale.x = 1
		sprite.flip_h = anim in ["idle", "punch_1"]
	else:
		pivot.scale.x = -1
		sprite.flip_h = anim not in ["idle", "punch_1"]

# -------------------------------------------------
# 8️⃣ SISTEMA DE DAÑO
# -------------------------------------------------
func take_damage(amount: float) -> void:
	if is_dead or is_invulnerable:
		return
	
	health -= amount
	health_changed.emit(health, max_health)
	
	# Efecto de retroceso
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(-last_direction * 30, 0), 0.1)
	tween.tween_property(self, "position", position, 0.1)
	
	# Activar invulnerabilidad
	is_invulnerable = true
	invulnerability_timer = invulnerability_duration
	
	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("idle")
	player_died.emit()
	
	# Animación de muerte
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", scale * 1.5, 0.5)
	
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	get_tree().call_group("main", "show_game_over")

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		var damage = 10.0
		if body.has_method("get_damage"):
			damage = body.get_damage()
		elif body.has("damage"):
			damage = body.damage
		take_damage(damage)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("enemies"):
		var damage = 10.0
		if parent.has_method("get_damage"):
			damage = parent.get_damage()
		elif parent.has("damage"):
			damage = parent.damage
		take_damage(damage)

# -------------------------------------------------
# 9️⃣ SEGURIDAD FIN DE ANIMACIÓN
# -------------------------------------------------
func _on_animation_finished():
	is_attacking_flag = false
