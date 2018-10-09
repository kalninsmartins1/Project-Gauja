extends TextureButton

enum Skill { NONE, FIRE_BALL, POTION_HP, POTION_MP }
export(Skill) var _skillId = 0
var _skillPanel = null

func _ready():
	_skillPanel = get_parent()
	pass
