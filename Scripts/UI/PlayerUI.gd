extends Container

export var _animateSpeed = 10

var _healthBar = null
var _manaBar = null
var _player = null
var _tween = null
var _inventoryPopup = null

func getPlayer():
	return _player

func _ready():
	_player = get_parent()
	_healthBar = get_node("Profile/GridContainer/GridContainer/Health")
	_manaBar = get_node("Profile/GridContainer/GridContainer/Mana")
	_tween = get_node("Tween")
	_inventoryPopup = get_node("InventoryPopup")
	
	_player.connect("onHealthChanged", self, "_onPlayerHealthChanged")
	_player.connect("onManaChanged", self, "_onPlayerManaChanged")
	_player.connect("onRequestInventoryOpen", self, "_onRequestInventoryOpen")
	pass

func _onRequestInventoryOpen():
	_inventoryPopup.show()
	pass

func _onPlayerHealthChanged(newValue):
	
	# Animate the health bar
	Utils.startProgressBarAnimation(_healthBar, _tween, _animateSpeed, newValue)
	pass
	
func _onPlayerManaChanged(newValue):
	
	# Animate the mana bar
	Utils.startProgressBarAnimation(_manaBar, _tween, _animateSpeed, newValue)
	pass