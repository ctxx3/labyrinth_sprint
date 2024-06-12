extends Area2D

# Constants
const TILE_SIZE = 16
const ANIMATION_SPEED = 6
const DIRECTIONS = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT,
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN
}

# Onready variables
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

# State variables
var is_moving = false
var current_direction = ""
var audio_cd = 1;

func _ready():
	position = position.snapped(Vector2.ONE * TILE_SIZE) + Vector2.ONE * TILE_SIZE / 2

func _unhandled_input(event):
	for direction in DIRECTIONS.keys():
		if event.is_action_pressed(direction) and not is_moving:
			start_moving(direction)
		elif event.is_action_released(direction):
			current_direction = ""
			if !is_moving:
				animated_sprite.stop()
				animated_sprite.frame = 1

func start_moving(direction):
	animated_sprite.play(direction)
	animated_sprite.flip_h = (direction == "ui_right")
	animated_sprite.frame = 0
	current_direction = direction

func move(direction):
	ray_cast.target_position = DIRECTIONS[direction] * TILE_SIZE
	ray_cast.force_raycast_update()
	
	if not ray_cast.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position", position + DIRECTIONS[direction] * TILE_SIZE, 1.0 / ANIMATION_SPEED)
		is_moving = true
		await tween.finished
		is_moving = false
		if current_direction == "":
			animated_sprite.stop()
			animated_sprite.frame = 1

func play_sound():
	audio.play()
	await get_tree().create_timer(1).timeout

func _process(delta):
	if current_direction != "" and not is_moving:
		move(current_direction)
	if(current_direction != ""):
			audio_cd -= 0.05
			if(audio_cd < 0):
				play_sound()
				audio_cd = 1
	else:
		audio_cd = 0

