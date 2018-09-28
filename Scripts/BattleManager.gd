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
	pass

func initiateBattle(var player, var enemy):
	_player = player
	_player.battleStarted(enemy)
	_player.connect("onHealthChanged", self, "_playerHealthChanged")
	_enemy = enemy
	_enemy.connect("onAttackFinished", self, "_enemyAttackFinished")
	_enemy.connect("onHealthChanged", self, "_enemyHealthChanged")
	
	_setCurrentTurn(_getRandomTurn())
	_skillSelectionPanel.show()
	pass

func finishTurn():
	if(_currentTurn == Turn.PLAYER):
		_setCurrentTurn(Turn.ENEMY)		
	else:
		_setCurrentTurn(Turn.PLAYER)
	pass

func _setCurrentTurn(turn):
	_currentTurn = turn
	if(_currentTurn == Turn.ENEMY):
		_enemy.setHasTurn(true)
	pass

func _enemyAttackFinished():
	finishTurn()
	pass

func _playerHealthChanged(health):
	if(health <= 0):
		_endBattle()
	pass
	
func _enemyHealthChanged(health):
	if(health <= 0):
		_endBattle()
	finishTurn()
	pass
	
func _endBattle():
	_skillSelectionPanel.hide()
	_player.battleEnded()
	_enemy.battleEnded()
	pass

func _getRandomTurn():
	randomize()
	var turn = randi() % 2 # Random value 0 or 1
	return turn

func _ready():
	_skillSelectionPanel = get_node("SkillSelectionPanel")	
	pass
