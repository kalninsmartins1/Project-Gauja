extends "res://Scripts/Items/Item.gd"

enum PotionType { HP, MP }
export(PotionType) var _potionType

export var _regenerateAmount = 0
