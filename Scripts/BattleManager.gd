extends Node


enum Turn { PLAYER, ENEMY }
var _player = null
var _enemy = null
var _isBattleActive = false
var _currentTurn = Turn.PLAYER
var _skillSelectionPanel = null

func onSkillButtonPressed(skillId):
	if(_currentTurn == Turn.PLAYER):
		if(_player.attack(_enemy, skillId)):
			finishTurn()
	pass

func initiateBattle(var player, var enemy):
	_player = player
	_player.battleStarted(enemy)
	_enemy = enemy
	_enemy.connect("onAttackFinished", self, "_enemyAttackFinished")
	
	_currentTurn = _getRandomTurn()
	_skillSelectionPanel.show()
	pass

func finishTurn():
	if(_currentTurn == Turn.PLAYER):
		_currentTurn = Turn.ENEMY
		_enemy.setHasTurn(true)
	else:
		_currentTurn = Turn.PLAYER
	pass

func _enemyAttackFinished():
	finishTurn()
	pass

func _getRandomTurn():
	var turn = randi() % 2 # Random value 0 or 1
	return turn
	pass

func _ready():
	_skillSelectionPanel = get_node("SkillSelectionPanel")	
	pass

func _process(delta):


	pass
