extends WindowDialog

export(PackedScene) var _slotTemplate

onready var _player = get_parent().get_parent()
onready var _helmetSlot = get_node("HBoxContainer/Character/HelmetSlot/Helmet")
onready var _armorSlot = get_node("HBoxContainer/Character/ArmorSlot/Armor")
onready var _glovesSlot = get_node("HBoxContainer/Character/GlovesSlot/Gloves")
onready var _weaponSlot = get_node("HBoxContainer/Character/WeaponSlot/Weapon")
onready var _bootsSlot = get_node("HBoxContainer/Character/BootsSlot/Boots")

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
	_player.connect("onInventoryChanged", self, "_onUpdateInventory")
	_inventoryItemContainer = get_node("HBoxContainer/Inventory/ScrollContainer/GridContainer")
	_initInventorySlots()
	_initCharacterSlots()
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
	_helmetSlot.connect("onItemPlaced", self, "_onItemPlaced")
	_armorSlot.connect("onItemPlaced", self, "_onItemPlaced")
	_glovesSlot.connect("onItemPlaced", self, "_onItemPlaced")
	_weaponSlot.connect("onItemPlaced", self, "_onItemPlaced")
	_bootsSlot.connect("onItemPlaced", self, "_onItemPlaced")
	pass
	
func _onItemPlaced():
	_activeInventorySlot.getItem().set_texture(null)
	pass
	
func _onSlotDragStarted(slot):
	_activeInventorySlot = slot
	pass

func _onSlotDragEnded(slot):
	_activeInventorySlot = null
	pass

func _onUpdateInventory():
	var inventory = _player.getInventory()
	var itemDetabase = _player.getItemDatabase()
	
	var index = 0
	for itemId in inventory:
		var item = itemDetabase.getItem(itemId)
		_inventorySlots[index].spawnItem(item)
		index += 1
	pass
