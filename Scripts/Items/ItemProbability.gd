extends Node

export(PackedScene) var _item
export(float, 0, 1, 0.01) var _probabilityNormalized = 0.0

func getItemId():
	return _item.resource_path.hash()

func getProbability():
	return _probabilityNormalized
