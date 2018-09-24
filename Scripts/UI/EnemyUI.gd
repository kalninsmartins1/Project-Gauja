extends TextureProgress

export var _animationSpeed = 10

var _utils = preload("res://Scripts/Utility/Utils.gd")
var _enemy = null
var _tween = null

func _ready():
	_enemy = get_parent()
	_tween = get_node("../Tween")
	
	_enemy.connect("onHealthChanged", self, "_onHealthChanged")
	pass
	
func _onHealthChanged(newValue):
	
	# Animate the health bar
	_utils.startProgressBarAnimation(self, _tween, _animationSpeed, newValue)
	pass

