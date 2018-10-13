extends TextureRect

enum ItemType { NONE, POTION, WEAPON, HELMET, ARMOR, GLOVES, BOOTS }
export(ItemType) var _requiredItemType

onready var _inventoryPopup = get_node("/root/Spatial/Player/PlayerUI/InventoryPopup")
onready var _slotRect = get_global_rect()

var _itemInSlot = null

signal onItemPlaced

func _input(event):
	if _inventoryPopup.is_visible() and event is InputEventMouseButton and !event.pressed and _slotRect.has_point(event.position):
		var item = _inventoryPopup.getActiveItem()
		if(item != null and item.getItemType() == _requiredItemType):
			set_texture(item.get_texture())
			_itemInSlot = item
			emit_signal("onItemPlaced")
	pass
