extends AcceptDialog

var _player = null
var _gridContainer = null

func _ready():
	_player = get_parent().get_parent()	
	_player.connect("onLootReceived", self, "_onLootAddedToInventory")
	_gridContainer = get_node("GridContainer")
	pass
	
func _onLootAddedToInventory(loot):
	var itemDatabase = _player.getItemDatabase()
	for itemId in loot:
		var item = itemDatabase.getItem(itemId).instance()
		_gridContainer.add_child(item)
	show()
	pass