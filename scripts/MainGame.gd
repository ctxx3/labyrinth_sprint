extends Node2D

@onready var tileset: TileMap = $TileMap
@onready var timeText: RichTextLabel = $CanvasLayer/TimeText
@onready var player: Area2D = $Player
@onready var startText: RichTextLabel = $CanvasLayer/StartText
@onready var endText: RichTextLabel = $CanvasLayer/EndText
var game_started = false
var game_ended = false

const time_template = "[b][i] Czas: {current_time}\nRekord: {best_time}"
const finish_template = "[center][b][i] Ukończono w\n[pulse color=#b0b0b0ff]{time} s {extra_text}[/pulse]\n\nnaciśnij ENTER aby kontynuować"

var start_time;

# Called when the node enters the scene tree for the first time.
func _ready():
	Variables.load_game()
	timeText.text = time_template.format({"current_time": "0.00", "best_time": Variables.best_time})
	TransitionScreen.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start_time != null and game_started:
		var time = ((Time.get_ticks_msec() - start_time) / 10) / 100.0
		timeText.text = time_template.format({"current_time": time, "best_time": Variables.best_time})

func _unhandled_input(event):
	if event.is_action_pressed("ui_text_newline"):
		if(game_ended):
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().reload_current_scene()
		
		elif not game_started:
			game_started = true
			var tween = create_tween()
			tween.tween_property(startText, "modulate", Color8(255,255,255,0), 1.0)
			var maze = await tileset.build_maze()
			startText.visible = false
			player.active = true
			start_time = Time.get_ticks_msec()
	if event.is_action_released("ui_cancel"):
		get_tree().quit()
	if event.is_action_released("restart"):
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().reload_current_scene()


func _on_player_at_exit():
	game_started = false
	game_ended = true
	player.active = false
	var time = ((Time.get_ticks_msec() - start_time) / 10) / 100.0
	var extra_text = ""
	if time < Variables.best_time:
		extra_text = "Nowy Rekord!"
		Variables.best_time = time
		timeText.text = time_template.format({"current_time": time, "best_time": Variables.best_time})
	endText.text = finish_template.format({"time":time,"extra_text":extra_text})
	Variables.save_game()
	endText.visible = true
