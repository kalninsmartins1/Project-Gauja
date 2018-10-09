extends Node

enum Turn { PLAYER, ENEMY }
var _player = null
var _enemy = null
var _isBattleActive = false
var _currentTurn = Turn.PLAYER

func getTarget():
	return _enemy

func initiateBattle(var player, var enemy):
	_player = player
	_player.battleStarted(enemy)
	_player.connect("onTurnFinished", self, "_turnFinished")
	_player.connect("onHealthChanged", self, "_playerHealthChanged")
	_enemy = enemy
	_enemy.connect("onTurnFinished", self, "_turnFinished")
	_enemy.connect("onHealthChanged", self, "_enemyHealthChanged")
	
	_setCurrentTurn(_getRandomTurn())
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
	if(_currentTurn == Turn.PLAYER):
		_enemy.setHasTurn(false)
		_player.setHasTurn(true)
	else:
		_enemy.setHasTurn(true)
		_player.setHasTurn(false)
	pass

func _turnFinished():
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
	
			if(Utils.isChanceHit(probability)):
				loot.append(lootEntry.getItemId())
				
	return loot
