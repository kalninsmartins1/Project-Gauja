extends Node

export(Array) var _itemDatabase
var _itemDictionary = {}
var _itemIdList = []

signal onItemDatabaseInitialized

func getItemIdList():
	return _itemIdList

func getItem(itemId):	
	return _itemDictionary[itemId]

func _ready():
	
	# Transfer list to dictionary for faster lookup
	for item in _itemDatabase:
		var id = item.resource_path.hash()
		_itemDictionary[id] = item		
		_itemIdList.append(id)
	emit_signal("onItemDatabaseInitialized")
	pass