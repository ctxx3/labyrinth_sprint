extends Area2D

func start_fall(duration: float):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	var target = position
	target.y += 16
	tween.tween_property(self, "position", target, duration)
	tween.tween_property(self, "scale", Vector2(1,1), duration)
	await tween.finished
