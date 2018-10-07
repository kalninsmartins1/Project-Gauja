extends Panel

var _animationPlayer = null
var _battleManager = null
var _isPanelVisible = false

func show():
	_animationPlayer.play("SkillSelectionUp")
	_isPanelVisible = true
	pass

func hide():
	_animationPlayer.play_backwards("SkillSelectionUp")
	_isPanelVisible = false
	pass

func onSkillButtonPressed(slotId):
	if(_isPanelVisible):

		# TODO: need to convert slotId to skillId
		# so skills can be dragged and dropped
		_battleManager.onSkillButtonPressed(slotId)
	pass

func _ready():
	_battleManager = get_parent()
	_animationPlayer = get_node("AnimationPlayer")
	pass
