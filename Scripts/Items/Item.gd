extends TextureRect

enum ItemType { NONE, POTION, WEAPON, HELMET, ARMOR, GLOVES, BOOTS }
export(ItemType) var _itemType

var _id = -1

func getId():
	return _id

func getItemType():
	return _itemType
	
func setId(id):
	_id = id
	pass
