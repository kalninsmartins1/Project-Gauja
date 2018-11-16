extends AcceptDialog

onready var _playerParty = get_parent().get_parent()
onready var _gridContainer = get_node("GridContainer")

func _ready():	
	_playerParty.connect("onLootReceived", self, "_onLootAddedToInventory")
	connect("confirmed", self, "_onHide")
	get_close_button().connect("pressed", self, "_onHide")
	pass
	
func _onHide():
	_removeAllItemsFromPopup()
	pass
	
func _onLootAddedToInventory(loot):
	if loot.size() > 0:
		var itemDatabase = _playerParty.getItemDatabase()
		for itemId in loot:
			var item = itemDatabase.getItem(itemId).instance()
			_gridContainer.add_child(item)
		show()
	pass
	
func _removeAllItemsFromPopup():
	var items = _gridContainer.get_children()
	for item in items:
		item.queue_free()
	pass