extends PanelContainer

export var _animateSpeed = 10

var _healthBar = null
var _manaBar = null
var _player = null
var _tween = null

func _getAnimationDuration(valueDiff):
	var duration = 0
	if(_animateSpeed > 0):
		duration = abs(valueDiff)/_animateSpeed
	
	return duration

func _ready():
	_player = get_parent()
	_healthBar = get_node("GridContainer/GridContainer/Health")
	_manaBar = get_node("GridContainer/GridContainer/Mana")
	_tween = get_node("Tween")
	
	_player.connect("onHealthChanged", self, "_onPlayerHealthChanged")
	_player.connect("onManaChanged", self, "_onPlayerManaChanged")
	pass

func _onPlayerHealthChanged(newValue):
	
	# Animate the health bar
	var duration = _getAnimationDuration(_healthBar.value - newValue)
	_tween.stop(_healthBar)
	_tween.interpolate_property(_healthBar, "value", _healthBar.value, newValue, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.start()
	pass
	
func _onPlayerManaChanged(newValue):
	
	# Animate the mana bar
	var duration = _getAnimationDuration(_manaBar.value - newValue)
	_tween.stop(_manaBar)
	_tween.interpolate_property(_manaBar, "value", _manaBar.value, newValue, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.start()
	pass