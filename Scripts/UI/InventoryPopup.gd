extends WindowDialog

export(PackedScene) var _slotTemplate

onready var _playerParty = get_parent().get_parent()

var _inventoryItemContainer = null
var _inventorySlots = []
var _characterSlots = []

func _ready():
	connect("about_to_show", self, "_aboutToShowPopup")
	_playerParty.connect("onInventoryItemAdded", self, "_addItemToInventorySlots")
	_playerParty.connect("onActivePlayerSwitched", self, "_onActivePlayerSwitched")
	_inventoryItemContainer = get_node("HBoxContainer/Inventory/ScrollContainer/GridContainer")
	_initInventorySlots()
	_initCharacterSlots()
	pass

func _aboutToShowPopup():
	_updateCharacterSlots()
	pass

func _onActivePlayerSwitched():
	_updateCharacterSlots()
	pass

func _updateCharacterSlots():
	var activePlayer = _playerParty.getActivePlayer()
	var itemDetabase = _playerParty.getItemDatabase()

	for charSlot in _characterSlots:
		var itemId = activePlayer.getEquipedItemId(charSlot.getItemType())
		if itemId != -1:
			var itemTemplate = itemDetabase.getItem(itemId)
			charSlot.spawnItem(itemTemplate, itemId)
		else:
			charSlot.clear()
	pass

func _initInventorySlots():
	for i in range(0, GameConsts.MAX_ITEMS):
		var itemSlot = _slotTemplate.instance()
		_inventorySlots.append(itemSlot)
		itemSlot.connect("onEquipItem", self, "_onEquipItem")
		_inventoryItemContainer.add_child(itemSlot)
	pass

func _initCharacterSlots():

	# Get all the character slots
	var slots = get_node("HBoxContainer/Character").get_children()
	for slot in slots:
		_characterSlots.append(slot.get_children()[0])
	pass

func _onEquipItem(item):
	_playerParty.getActivePlayer().setEquipedItemId(item)
	_updateCharacterSlots()
	pass

func _addItemToInventorySlots(itemId):
	var itemDetabase = _playerParty.getItemDatabase()
	var itemTemplate = itemDetabase.getItem(itemId)
	var slot = _findEmptyInventorySlot()
	slot.spawnItem(itemTemplate, itemId)
	pass

func _findEmptyInventorySlot():
	var keySlot = null

	for slot in _inventorySlots:
		if slot.isEmpty():
			keySlot = slot
			break
	return keySlot
