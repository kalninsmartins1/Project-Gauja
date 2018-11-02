extends Label

export var _animationTime = 2.0

func startFloating(startPos, text, color):
	set_text(text)
	add_color_override("font_color", color)
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_position", startPos, startPos + Vector2(0, -20), _animationTime, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_callback(self, _animationTime, "_onFinishedFloating")
	tween.start()
	pass
	
func _onFinishedFloating():
	queue_free()
	pass
