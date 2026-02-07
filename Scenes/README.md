# Mapa Beat'em Up 2.5D para Godot 4 (2D)

Mapa completamente 2D listo para usar en tu juego beat'em up estilo Streets of Rage, Final Fight, TMNT, etc.

## 📦 Archivos incluidos

- `BeatEmUpMap.tscn` - Escena principal del mapa (2D)
- `BeatEmUpMap.gd` - Script del mapa con sistema de sorting
- `Character.gd` - Plantilla para tus personajes
- `FollowCamera.gd` - Script de cámara que sigue al jugador

## 🚀 Cómo usar

### 1. Importar a tu proyecto

1. Copia los 4 archivos a tu proyecto Godot 4
2. Abre `BeatEmUpMap.tscn` en el editor

### 2. Crear tu personaje

```gdscript
# Estructura básica de tu personaje:
CharacterBody2D (con script Character.gd)
├── CollisionShape2D (forma: CapsuleShape2D o RectangleShape2D)
├── Sprite2D o AnimatedSprite2D (tu sprite/animación)
└── AnimationPlayer (opcional)
```

**IMPORTANTE para las colisiones:**
1. Tu personaje DEBE tener un `CollisionShape2D`
2. En las propiedades de tu CharacterBody2D:
   - **Collision Layer**: Marca la capa 1
   - **Collision Mask**: Marca la capa 1
3. El script `Character.gd` ya configura esto automáticamente

### 3. Configurar la cámara para seguir al jugador

**Opción A - Automática (más fácil):**
1. Añade tu personaje al mapa
2. Añade el personaje al grupo "player":
   - Selecciona tu personaje
   - Ve a Inspector > Node > Groups
   - Escribe "player" y dale a Add
3. ¡Listo! La cámara lo seguirá automáticamente

**Opción B - Manual:**
1. Selecciona el nodo `Camera2D` en el mapa
2. En el Inspector, arrastra tu personaje al campo "Target"

### 4. Añadir personajes al mapa

Arrastra tus personajes a la escena o instáncialos por código:

```gdscript
# Instanciar jugador
var player = preload("res://player.tscn").instantiate()
player.global_position = $PlayerSpawnPoints/SpawnPoint1.global_position
player.add_to_group("player")  # Para que la cámara lo encuentre
add_child(player)
```

## 🎮 Características del mapa

### Mapa completamente 2D
- Resolución: 1600x600 píxeles
- Área jugable: aproximadamente 1472x472 píxeles
- Fondo y suelo con colores diferenciados
- Líneas de profundidad para guiar el movimiento

### Cámara que sigue al jugador
- Seguimiento suave con interpolación
- Límites para no salirse del mapa
- Ajustable en el Inspector:
  - `Follow Smoothing`: Velocidad del seguimiento (5.0 por defecto)
  - `Enable Bounds`: Activar/desactivar límites

### Sistema de sorting automático (Z-Index)
- Los personajes más arriba (menor Y) se dibujan atrás
- Los personajes más abajo (mayor Y) se dibujan adelante
- Automático según posición Y

### Sistema de colisiones
- Paredes invisibles en los 4 bordes
- Suelo y techo con colisiones
- Las colisiones funcionan en capa 1

### Puntos de spawn
- **Jugadores**: 2 puntos en la izquierda (Y: 250 y 350)
- **Enemigos**: 3 puntos en la derecha
- Fácilmente extensible añadiendo más Marker2D

### Props incluidos
- 2 cajas de ejemplo (visuales solamente)
- Puedes añadir más decoración fácilmente

## 🎯 Controles predeterminados

El script `Character.gd` usa los controles estándar de Godot:
- **Flechas/WASD**: Movimiento en 4 direcciones
  - ← →: Movimiento horizontal
  - ↑ ↓: Movimiento en profundidad
- El sprite se voltea automáticamente según dirección
- Puedes añadir botones de ataque en `handle_player_input()`

## 🐛 Solución de problemas

### El personaje no colisiona con las paredes:

✅ **Solución:**
1. Asegúrate de que tu personaje tenga un `CollisionShape2D`
2. Verifica que el personaje sea un `CharacterBody2D`
3. En el Inspector del personaje:
   - Collision > Layer: Marca la capa 1
   - Collision > Mask: Marca la capa 1
4. El script ya incluye `collision_layer = 1` y `collision_mask = 1`

### La cámara no sigue al jugador:

✅ **Solución:**
1. Añade tu personaje al grupo "player":
   ```gdscript
   # En el código:
   player.add_to_group("player")
   
   # O en el editor:
   # Selecciona el personaje > Inspector > Node > Groups > "player"
   ```
2. O asigna manualmente en Camera2D > Target

### Los personajes no se superponen correctamente:

✅ **Solución:**
- El z_index se asigna automáticamente según posición Y
- Asegúrate de que `z_as_relative = false` en tu personaje
- Verifica que el personaje esté registrado en el mapa

### El personaje se mueve muy rápido/lento:

✅ **Solución:**
- Ajusta el parámetro `speed` en Character.gd (200.0 por defecto)
- Valor recomendado: entre 150-300

## ⚙️ Personalización de la cámara

En el Inspector de Camera2D puedes ajustar:

```
Follow Smoothing: 5.0  # Velocidad de seguimiento
Enable Bounds: true  # Límites del mapa
Min X / Max X: 576 / 1024  # Límites horizontales
Min Y / Max Y: 300 / 300  # Límites verticales
```

## ⚙️ Personalización del mapa

### Cambiar tamaño del mapa

1. En la escena, modifica el tamaño de:
   - `Background` (ColorRect)
   - `Floor` (ColorRect)
   - Las colisiones en `Boundaries`

2. En `BeatEmUpMap.gd`, modifica:
```gdscript
const MAP_BOUNDS = {
    "min_x": 64.0,   # Límite izquierdo
    "max_x": 1536.0, # Límite derecho
    "min_y": 64.0,   # Límite superior
    "max_y": 536.0   # Límite inferior
}
```

### Cambiar colores del mapa

En el Inspector, selecciona:
- `Background` > Color: Color del fondo
- `Floor` > Color: Color del suelo

O usa texturas en lugar de colores sólidos.

### Añadir decoración

Puedes añadir bajo el nodo `Props`:
- **Sprite2D**: Para decoración estática
- **AnimatedSprite2D**: Para decoración animada
- **StaticBody2D + Sprite2D**: Para objetos con colisión

### Añadir texturas/sprites

Reemplaza los ColorRect por Sprite2D:
```gdscript
# Ejemplo para el suelo:
var floor_sprite = Sprite2D.new()
floor_sprite.texture = preload("res://suelo.png")
floor_sprite.position = Vector2(800, 568)
```

## 📋 Funciones útiles del mapa

```gdscript
# Registrar personaje en sistema de sorting
map.register_character(character_node)

# Obtener spawn point
var pos = map.get_spawn_point("SpawnPoint1")

# Spawn aleatorio de enemigo
var enemy_pos = map.get_random_enemy_spawn()

# Verificar si está dentro del mapa
if map.is_within_bounds(position):
    # hacer algo

# Forzar posición dentro de límites
new_position = map.clamp_to_bounds(position)
```

## 🎨 Mejoras sugeridas

1. **Texturas**: Reemplaza ColorRect por Sprite2D con texturas
2. **Parallax**: Añade ParallaxBackground para fondos con profundidad
3. **Props**: Añade barriles, cajas, farolas, etc. como Sprite2D
4. **Sombras**: Añade sprites de sombra debajo de los personajes
5. **Partículas**: Efectos de polvo, chispas, etc.
6. **Iluminación**: Usa CanvasModulate y Light2D para efectos de luz
7. **Audio**: Añade AudioStreamPlayer para música de fondo

## 📝 Ejemplo de personaje completo

```gdscript
# Crear un personaje simple:
CharacterBody2D "Player"
├── CollisionShape2D (CapsuleShape2D: radio=20, altura=60)
├── Sprite2D (texture: tu_sprite.png, centered: true)
└── Script: Character.gd
```

En el Inspector del Player:
- Collision > Layer: Capa 1 ✓
- Collision > Mask: Capa 1 ✓
- Node > Groups: "player" ✓

## 📝 Notas técnicas

- **Eje Y**: Controla tanto altura como profundidad en 2.5D
  - Menor Y = más arriba/atrás = se dibuja primero
  - Mayor Y = más abajo/adelante = se dibuja encima
- **Eje X**: Movimiento lateral (izquierda/derecha)
- **Z-Index**: Se calcula automáticamente según posición Y
- **Colisiones**: Usan la capa 1 por defecto
- **Resolución**: 1600x600 (ajústala a tu necesidad)

## ✅ Checklist rápido

- [ ] Archivos copiados al proyecto
- [ ] Personaje con CollisionShape2D
- [ ] Personaje con Sprite2D o AnimatedSprite2D
- [ ] Personaje en grupo "player"
- [ ] Collision Layer y Mask en capa 1
- [ ] Script Character.gd aplicado al personaje
- [ ] Probar el juego

## 🎮 Configuración de Input Map

Asegúrate de tener estos inputs en Project > Project Settings > Input Map:
- `ui_left`: Flecha izquierda / A
- `ui_right`: Flecha derecha / D
- `ui_up`: Flecha arriba / W
- `ui_down`: Flecha abajo / S

¡Disfruta creando tu beat'em up! 🥊
