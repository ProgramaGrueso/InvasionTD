extends CharacterBody2D

# -------------------------------------------------
# 1️⃣ CONFIGURACIÓN
# -------------------------------------------------
@export var speed := 250.0
@export var damage_punch := 20.0
@export var damage_finisher := 60.0

# DASH
@export var dash_speed := 700.0
@export var dash_duration := 0.15
@export var dash_cooldown := 0.5

# COMBOS
const COMBO_WINDOW := 0.5
var combo_step := 0
var combo_timer := 0.0
var is_attacking_flag := false
var last_direction := 1

# DASH STATE
var is_dashing := false
var dash_timer := 0.0
var dash_cd_timer := 0.0

# REFERENCIAS
@onready var sprite = $AnimatedSprite2D
@onready var pivot = $HitboxPivot
@onready var hitbox_area = $HitboxPivot/Hitbox
@onready var attack_area_shape = $HitboxPivot/Hitbox/CollisionShape2D

# -------------------------------------------------
# 2️⃣ READY
# -------------------------------------------------
func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	apply_transparent_shader()

	if attack_area_shape:
		attack_area_shape.disabled = true

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
	# Combo timer
	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_step = 0
	
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
		return

	# ATAQUE (Z)
	if Input.is_key_pressed(KEY_Z) and not is_attacking_flag:
		perform_attack()
		return

	# MOVIMIENTO NORMAL
	if not is_attacking_flag:
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
			var dmg = damage_finisher if combo_step == 0 else damage_punch
			target.take_damage(dmg)

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
# 8️⃣ SEGURIDAD FIN DE ANIMACIÓN
# -------------------------------------------------
func _on_animation_finished():
	is_attacking_flag = false
