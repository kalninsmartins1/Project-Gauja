extends Container

onready var _playerParty = get_parent()
onready var _inventoryPopup = get_node("InventoryPopup")
onready var _skillSelectionPanel = get_node("SkillSelectionPanel")
onready var _playerProfilesContainer = get_node("PlayerProfiles")
onready var _dialogPanel = get_node("DialogPanel")
onready var _tween = get_node("Tween")

var _characterProfiles = []

signal onActivePlayerSwitchRequest
signal onDialogClosed

func getPlayer():
	return _playerParty.getActivePlayer()

func onActivePlayerChanged(playerId):
	for profile in _characterProfiles:
		if profile.getPlayerId() == playerId:
			profile.setActiveState(true)
		else:
			profile.setActiveState(false)
	pass

func addCharacterProfile(player):
	var profile = player.getProfileTemplate().instance()
	profile.init(player, _tween)
	profile.connect("onActivePlayerSwitchRequest", self, "_onActivePlayerSwitchRequest")
	_characterProfiles.append(profile)
	_playerProfilesContainer.add_child(profile)	
	pass

func startDialog(dialog):
	_dialogPanel.startDialog(dialog)
	pass

func _ready():		
	_playerParty.connect("onRequestInventoryOpen", self, "_onRequestInventoryOpen")
	_playerParty.connect("onBattleStarted", self, "_onPlayerEnterBattle")
	_playerParty.connect("onBattleEnded", self, "_onPlayerExitBattle")
	_dialogPanel.connect("onClosed", self, "_onDialogPanelClosed")
	pass

func _onDialogPanelClosed():
	emit_signal("onDialogClosed")
	pass

func _onActivePlayerSwitchRequest(playerId):
	emit_signal("onActivePlayerSwitchRequest", playerId)
	pass

func _onRequestInventoryOpen():
	_inventoryPopup.popup()
	pass

func _onPlayerEnterBattle():
	_skillSelectionPanel.show()
	pass

func _onPlayerExitBattle():
	_skillSelectionPanel.hide()
	pass