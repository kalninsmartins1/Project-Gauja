extends Node

export(Array) var _itemDatabase
var _itemDictionary = {}

func getItem(itemId):	
	return _itemDictionary[itemId]

func _ready():
	
	# Transfer list to dictionary for faster lookup
	for item in _itemDatabase:
		var id = item.resource_path.hash()
		_itemDictionary[id] = item
	pass