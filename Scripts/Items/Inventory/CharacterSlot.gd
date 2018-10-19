extends "res://Scripts/Items/Item.gd"

onready var _inventoryPopup = get_node("/root/Spatial/PlayerParty/PlayerUI/InventoryPopup")

func getItemType():
	return _itemType
	
func spawnItem(itemTemplate, itemId):
	setId(itemId)
	var item = itemTemplate.instance()
	set_texture(item.get_texture())
	pass
	
func clear():
	set_texture(null)
	setId(-1)
	pass
