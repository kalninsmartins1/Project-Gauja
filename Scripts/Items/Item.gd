extends TextureRect

enum ItemType { NONE, POTION, WEAPON, HELMET, ARMOR, GLOVES, BOOTS }
export(ItemType) var _itemType

func getItemType():
	return _itemType