extends TextureProgress

export var _animationSpeed = 10

var _enemy = null
var _tween = null

func _ready():
	_enemy = get_parent()
	_tween = get_node("../Tween")
	
	_enemy.connect("onHealthChanged", self, "_onHealthChanged")
	pass
	
func _onHealthChanged(enemy):
	
	# Animate the health bar
	var newHealthValue = enemy.getHealth()
	Utils.startProgressBarAnimation(self, _tween, _animationSpeed, newHealthValue)
	pass

