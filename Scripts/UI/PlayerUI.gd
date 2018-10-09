extends Container

export var _animateSpeed = 10

onready var _player = get_parent()
onready var _healthBar = get_node("Profile/GridContainer/GridContainer/Health")
onready var _manaBar = get_node("Profile/GridContainer/GridContainer/Mana")
onready var _tween = get_node("Tween")
onready var _inventoryPopup = get_node("InventoryPopup")
onready var _skillSelectionPanel = get_node("SkillSelectionPanel")

func getPlayer():
	return _player

func _ready():	
	_player.connect("onHealthChanged", self, "_onPlayerHealthChanged")
	_player.connect("onManaChanged", self, "_onPlayerManaChanged")
	_player.connect("onRequestInventoryOpen", self, "_onRequestInventoryOpen")
	_player.connect("onBattleStarted", self, "_onPlayerEnterBattle")
	_player.connect("onBattleEnded", self, "_onPlayerExitBattle")
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

func _onPlayerEnterBattle():
	_skillSelectionPanel.show()
	pass

func _onPlayerExitBattle():
	_skillSelectionPanel.hide()
	pass