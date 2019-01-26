extends Spatial

onready var _animationTree = get_node("AnimationTreePlayer")
onready var _physicsBody = get_node("KinematicBody")
onready var _playerParty = get_node("../PlayerParty")

export(Array, String) var _defaultDialog
export(Array) var _quests
export var _interactDistance = 4

var _activeQuest = null
var _isFinishingQuest = false

func _ready():
	Utils.setAnimationLooping(_animationTree, GameConsts.ANIM_IDLE_ID)
	_physicsBody.connect("input_event", self, "_onMouseEvent")
	_playerParty.connect("onDialogClosed", self, "_onDialogClosed")
	pass

func _onMouseEvent(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		var activePlayer = _playerParty.getActivePlayer()
		var toPlayer = activePlayer.get_global_transform().origin - get_global_transform().origin
		if toPlayer.length_squared() < _interactDistance * _interactDistance:
			_onInteract()
	pass

func _onDialogClosed():
	if _isFinishingQuest:
		_playerParty.onQuestCompleted(_activeQuest)
		_activeQuest.queue_free()
		_activeQuest = null
		_isFinishingQuest = false

	elif _activeQuest != null:
		_playerParty.startQuest(_activeQuest)
	pass

func _onInteract():
	if _activeQuest != null:

		# A quest is currently active
		_handleActiveQuest()
	else:
		_tryToBeginNewQuest()
	pass

func _handleActiveQuest():
	if _activeQuest.isCompleted():

		# Quest completed
		_playerParty.startDialog(_activeQuest.getEndDialog())
		_isFinishingQuest = true
	else:

		# Quest in progress
		_playerParty.startDialog(_activeQuest.getActiveDialog())
	pass

func _tryToBeginNewQuest():
	var startQuest = _findNextNotCompletedQuest()
	if startQuest != null:

		# We have uncompleted quests
		_activeQuest = startQuest.instance()
		_activeQuest.setId(startQuest.get_path().hash())
		_playerParty.startDialog(_activeQuest.getStartDialog())
	else:

		# All quests have been completed
		_playerParty.startDialog(_defaultDialog)
	pass

func _findNextNotCompletedQuest():
	var completedQuestIds = _playerParty.getCompletedQuestIds()
	var keyQuest = null

	for quest in _quests:
		var questId = quest.get_path().hash()
		if !completedQuestIds.has(questId):
			keyQuest = quest
			break

	return keyQuest