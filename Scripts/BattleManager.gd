extends Node


enum Turn { PLAYER, ENEMY }
var _player = null
var _enemy = null
var _isBattleActive = false
var _currentTurn = Turn.PLAYER
var _skillSelectionPanel = null

func onSkillButtonPressed(skillId):
	if(_currentTurn == Turn.PLAYER):
		_player.attack(_enemy, skillId)
		finishTurn()
	pass

func initiateBattle(var player, var enemy):
	_player = player
	_player.battleStarted(enemy)
	_enemy = enemy
	_currentTurn = _getRandomTurn()
	_skillSelectionPanel.show()
	pass

func finishTurn():
	if(_currentTurn == Turn.PLAYER):
		_currentTurn = Turn.ENEMY
		_enemy.setReadyToAttack(true)
	else:
		_currentTurn = Turn.PLAYER
	pass

func _getRandomTurn():
	var turn = randi() % 2 # Random value 1 or 2
	return turn
	pass

func _ready():
	_skillSelectionPanel = get_child(0)
	pass

func _process(delta):


	pass
