extends TextureButton

export var _slotId = 0
var _skillPanel = null

func _ready():
	_skillPanel = get_parent()
	pass

# TODO: This looks very strange, need to give this a better thought
func _process(delta):
	if(Input.is_action_pressed("skill_0") and _slotId == 0):
		_skillPanel.onSkillButtonPressed(_slotId)
	elif(Input.is_action_pressed("skill_1") and _slotId == 1):
		_skillPanel.onSkillButtonPressed(_slotId)
	pass
