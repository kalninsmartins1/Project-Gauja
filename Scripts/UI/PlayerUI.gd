extends Container

export var _animateSpeed = 10

var _utils = preload("res://Scripts/Utility/Utils.gd")
var _healthBar = null
var _manaBar = null
var _player = null
var _tween = null

func getPlayer():
	return _player

func _ready():
	_player = get_parent()
	_healthBar = get_node("Profile/GridContainer/GridContainer/Health")
	_manaBar = get_node("Profile/GridContainer/GridContainer/Mana")
	_tween = get_node("Tween")
	
	_player.connect("onHealthChanged", self, "_onPlayerHealthChanged")
	_player.connect("onManaChanged", self, "_onPlayerManaChanged")
	pass

func _onPlayerHealthChanged(newValue):
	
	# Animate the health bar
	_utils.startProgressBarAnimation(_healthBar, _tween, _animateSpeed, newValue)
	pass
	
func _onPlayerManaChanged(newValue):
	
	# Animate the mana bar
	_utils.startProgressBarAnimation(_manaBar, _tween, _animateSpeed, newValue)
	pass