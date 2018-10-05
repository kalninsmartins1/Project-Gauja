extends Node

enum Turn { PLAYER, ENEMY }
var _player = null
var _enemy = null
var _isBattleActive = false
var _currentTurn = Turn.PLAYER
var _skillSelectionPanel = null
var _utils = preload("res://Scripts/Utility/Utils.gd")

func onSkillButtonPressed(skillId):
	if(_currentTurn == Turn.PLAYER):
		_player.attack(_enemy, skillId)
	pass

func initiateBattle(var player, var enemy):
	_player = player
	_player.battleStarted(enemy)
	_player.connect("onAttackFinished", self, "_attackFinished")
	_player.connect("onHealthChanged", self, "_playerHealthChanged")
	_enemy = enemy
	_enemy.connect("onAttackFinished", self, "_attackFinished")
	_enemy.connect("onHealthChanged", self, "_enemyHealthChanged")
	
	_setCurrentTurn(_getRandomTurn())
	_skillSelectionPanel.show()
	_isBattleActive = true
	pass

func finishTurn():
	if(_isBattleActive):
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

func _attackFinished():
	finishTurn()
	pass

func _playerHealthChanged(health):
	if(health <= 0):
		_endBattle(false)
	pass
	
func _enemyHealthChanged(health):
	if(health <= 0):
		_endBattle(true)	
	pass
	
func _endBattle(var shouldGiveLoot):
	_skillSelectionPanel.hide()
	
	var lootArray = null
	if(shouldGiveLoot):
		lootArray = _calculateLoot()
				
	_player.battleEnded(lootArray)
	_enemy.battleEnded()
	_isBattleActive = false
	pass

func _getRandomTurn():
	randomize()
	var turn = randi() % 2 # Random value 0 or 1
	return turn
	
func _calculateLoot():	
	var loot = []
	var table = _enemy.getLootTable()
	
	for row in table:
		for cell in row:
			var lootEntry = cell.instance()
			var probability = lootEntry.getProbability()
	
			if(_utils.isChanceHit(probability)):
				loot.append(lootEntry.getItemId())
				
	return loot

func _ready():
	_skillSelectionPanel = get_node("SkillSelectionPanel")	
	pass
