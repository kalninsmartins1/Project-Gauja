extends Panel

export var _animateSpeed = 10

onready var _healthBar = get_node("GridContainer/GridContainer/Health")
onready var _manaBar = get_node("GridContainer/GridContainer/Mana")

var _tween = null
var _playerId = -1
var _style = StyleBoxFlat.new()

signal onActivePlayerSwitchRequest

func getPlayerId():
	return _playerId

func setActiveState(isActive):
	
	add_stylebox_override("panel", _style)
	
	if isActive:
		_style.set_bg_color(Color(0, 0, 1))
	else:
		_style.set_bg_color(Color(0, 0, 0))
	pass
	
func init(player, tween):
	player.connect("onHealthChanged", self, "_onPlayerHealthChanged")
	player.connect("onManaChanged", self, "_onPlayerManaChanged")
	_playerId = player.getId()
	_tween = tween
	
	setActiveState(false)
	pass

func _gui_input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		emit_signal("onActivePlayerSwitchRequest", _playerId)
	pass

func _onHealthChanged(newValue):
	
	# Animate the health bar
	Utils.startProgressBarAnimation(_healthBar, _tween, _animateSpeed, newValue)
	pass
	
func _onManaChanged(newValue):
	
	# Animate the mana bar
	Utils.startProgressBarAnimation(_manaBar, _tween, _animateSpeed, newValue)
	pass
