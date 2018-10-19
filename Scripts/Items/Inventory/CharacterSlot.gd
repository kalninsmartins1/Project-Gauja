extends "res://Scripts/Items/Item.gd"

onready var _inventoryPopup = get_node("/root/Spatial/PlayerParty/PlayerUI/InventoryPopup")
onready var _slotRect = get_global_rect()

var _itemInSlot = null

signal onItemPlaced

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
	
func _input(event):
	if _inventoryPopup.is_visible() and event is InputEventMouseButton and !event.pressed and _slotRect.has_point(event.position):
		var item = _inventoryPopup.getActiveItem()
		if(item != null and item.getItemType() == _itemType):
			set_texture(item.get_texture())
			_itemInSlot = item
			emit_signal("onItemPlaced", item)
	pass
