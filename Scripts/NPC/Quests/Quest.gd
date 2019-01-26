extends Node

export(Array, String) var _startDialog
export(Array, String) var _activeDialog
export(Array, String) var _endDialog
export var _requiredAmount = 0
export var _questTitle = ""

var _id = -1
var _curAmount = 0

func getQuestType():
	return GameConsts.QuestType.NONE

func getTitle():
	return _questTitle

func getId():
	return _id

func getStartDialog():
	return _startDialog

func getActiveDialog():
	return _activeDialog

func getEndDialog():
	return _endDialog

func getCollectedAmount():
	return _curAmount

func getRequiredAmount():
	return _requiredAmount

func isCompleted():
	return _curAmount == _requiredAmount

func setId(id):
	_id = id
	pass

func collect():
	_curAmount += 1
	_curAmount = clamp(_curAmount, 0, _requiredAmount)
	pass

