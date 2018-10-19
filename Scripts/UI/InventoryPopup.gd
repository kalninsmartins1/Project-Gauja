extends WindowDialog

export(PackedScene) var _slotTemplate

onready var _playerParty = get_parent().get_parent()

var _inventoryItemContainer = null
var _inventorySlots = []
var _characterSlots = []
var _activeInventorySlot = null

func getActiveItem():
	var item = null
	if _activeInventorySlot != null:
		item = _activeInventorySlot.getItem()
	return item
	
func _ready():	
	connect("about_to_show", self, "_aboutToShowPopup")
	_playerParty.connect("onInventoryChanged", self, "_updateInventorySlots")
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
		itemSlot.connect("onItemDragStarted", self, "_onSlotDragStarted")
		itemSlot.connect("onItemDragEnded", self, "_onSlotDragEnded")
		_inventoryItemContainer.add_child(itemSlot)
	pass

func _initCharacterSlots():
	
	# Get all the character slots
	var slots = get_node("HBoxContainer/Character").get_children()
	for slot in slots:
		_characterSlots.append(slot.get_children()[0])
	
	# Listen for item placed signal
	for charSlot in _characterSlots:
		charSlot.connect("onItemPlaced", self, "_onItemPlaced")	
	pass
	
func _onItemPlaced(item):
	_playerParty.getActivePlayer().setEquipedItemId(item)	
	_activeInventorySlot.getItem().set_texture(null)	
	pass
	
func _onSlotDragStarted(slot):
	_activeInventorySlot = slot
	pass

func _onSlotDragEnded(slot):
	_activeInventorySlot = null
	pass

func _updateInventorySlots():
	var inventory = _playerParty.getInventory()
	var itemDetabase = _playerParty.getItemDatabase()
	
	var index = 0
	for itemId in inventory:
		var itemTemplate = itemDetabase.getItem(itemId)		
		_inventorySlots[index].spawnItem(itemTemplate, itemId)
		index += 1
	pass
