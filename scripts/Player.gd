extends Area2D

signal at_exit;

# Onready variables
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

# Constants
const TILE_SIZE = 16
const ANIMATION_SPEED = 6
const DIRECTIONS = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

# Held keys
var moving = {
	"ui_right": false,
	"ui_left": false,
	"ui_up": false,
	"ui_down": false
}

# State variables
var is_moving = false
var audio_cd = 1;
var active = false

func _ready():
	position = position.snapped(Vector2.ONE * TILE_SIZE) + Vector2.ONE * TILE_SIZE / 2

func _unhandled_input(event):
	for direction in DIRECTIONS.keys():
		if event.is_action_pressed(direction):
			moving[direction] = true
		if event.is_action_released(direction):
			moving[direction] = false
			if !is_moving:
				animated_sprite.stop()
				animated_sprite.frame = 1

func move():
	var first = null
	for key in moving:
		if(moving[key]):
			first = key
			
			#collision check
			ray_cast.target_position = DIRECTIONS[key] * TILE_SIZE
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding() or !active: continue
			
			animate(key)
			
			#animate moving forward
			var tween = create_tween()
			tween.tween_property(self, "position", position + DIRECTIONS[key] * TILE_SIZE, 1.0 / ANIMATION_SPEED)
			is_moving = true
			await tween.finished

			is_moving = false
			if(position == Vector2(-120, -104)):
				at_exit.emit()
			if !moving[key]:
				animated_sprite.stop()
				animated_sprite.frame = 1
			return
	if first != null:
		animate(first)


func animate(direction):
	if !animated_sprite.is_playing() or animated_sprite.animation != direction:
		animated_sprite.play(direction)
		animated_sprite.flip_h = (direction == "ui_right")
		animated_sprite.frame = 0

func _process(delta):
	if moving.values().has(true):
		if not is_moving:
			move()
		audio_cd -= 0.05
		if audio_cd < 0:
			if is_moving:
				audio.play()
			audio_cd = 1.0
	else:
		audio_cd = 0
