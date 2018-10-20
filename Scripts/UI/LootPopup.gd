extends AcceptDialog

var _playerParty = null
var _gridContainer = null

func _ready():
	_playerParty = get_parent().get_parent()	
	_playerParty.connect("onLootReceived", self, "_onLootAddedToInventory")
	_gridContainer = get_node("GridContainer")
	pass
	
func _onLootAddedToInventory(loot):
	if loot.size() > 0:
		var itemDatabase = _playerParty.getItemDatabase()
		for itemId in loot:
			var item = itemDatabase.getItem(itemId).instance()
			_gridContainer.add_child(item)
		show()
	pass