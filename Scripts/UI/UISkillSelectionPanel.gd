extends Panel

export var _animDuration = 1.0

onready var _viewport = get_node("/root")
onready var _tween = get_node("Tween")

var _outPosition = null
var _inPosition = null
var _isShowing = false

func show():
	_isShowing = true
	_tween.stop(self)
	_tween.interpolate_property(self, "rect_position", rect_position, _inPosition, _animDuration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.start()
	pass

func hide():
	_isShowing = false
	_tween.stop(self)
	_tween.interpolate_property(self, "rect_position", rect_position, _outPosition, _animDuration, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	_tween.start()
	pass

func _ready():
	_setInOutPositions()
	_viewport.connect("size_changed", self, "_viewportResized")
	pass

func _viewportResized():
	_setInOutPositions()
	pass

func _setInOutPositions():
	var centerPosX = _viewport.size.x/2 - rect_size.x/2
	_outPosition = Vector2(centerPosX, _viewport.size.y + rect_size.y)
	_inPosition = Vector2(centerPosX, _viewport.size.y - rect_size.y)
	if(_isShowing):
		rect_position = _inPosition
	else:
		rect_position = _outPosition		
	pass
