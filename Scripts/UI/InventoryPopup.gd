extends WindowDialog

export(PackedScene) var _slotTemplate 
var _player = null
var _inventoryItemContainer = null
var _inventorySlots = []

func _ready():
	_player = get_parent().get_parent()
	_player.connect("onInventoryChanged", self, "_onUpdateInventory")
	_inventoryItemContainer = get_node("HBoxContainer/Inventory/ScrollContainer/GridContainer")
	_initInventorySlots()
	pass

func _initInventorySlots():
	for i in range(0, GameConsts.MAX_ITEMS):
		var itemSlot = _slotTemplate.instance()
		_inventorySlots.append(itemSlot)
		_inventoryItemContainer.add_child(itemSlot)
	pass	

func _onUpdateInventory():
	var inventory = _player.getInventory()
	var itemDetabase = _player.getItemDatabase()
	
	var index = 0
	for itemId in inventory:
		var item = itemDetabase.getItem(itemId)
		_inventorySlots[index].setTemplate(item)
		index += 1
	pass
