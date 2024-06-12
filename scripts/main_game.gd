extends Node2D

@onready var label: RichTextLabel = $CanvasLayer/RichTextLabel

var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	time = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = str( round((Time.get_ticks_msec() - time) / 10) / 100.0)
