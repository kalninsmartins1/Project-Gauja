extends Node

enum Turn { PLAYER, ENEMY }

const EnemyParty = preload("res://Scripts/Enemy/EnemyParty.gd")

var _playerParty = null
var _enemyParty = null
var _isBattleActive = false
var _currentTurn = Turn.PLAYER

func getActiveEnemy():
	return _enemyParty.getActiveEnemy()

func getActivePlayer():
	return _playerParty.getActivePlayer()

func canEnterBattle():
	return _enemyParty == null or (!_enemyParty.isPartyFull() and _enemyParty.IsBattlePositionsSet())

func initiateBattle(var playerParty, var enemy):
	if _enemyParty == null:

		# Setup player party
		_playerParty = playerParty
		_playerParty.onBattleStarted(enemy)
		_playerParty.connect("onTurnFinished", self, "_onFinishedTurn")
		_playerParty.connect("onPartyLost", self, "_partyLost")

		# Setup enemy party
		_enemyParty = EnemyParty.new() # Enemies should be in party only while in battle
		_enemyParty.onBattleStarted(self)
		_enemyParty.connect("onTurnFinished", self, "_onFinishedTurn")
		_enemyParty.connect("onPartyLost", self, "_partyLost")
		_enemyParty.addEnemy(enemy)	

		_calculateNextTurn()
		_isBattleActive = true

	elif !_enemyParty.isPartyFull():
		_enemyParty.addEnemy(enemy)
	pass

func finishTurn():
	if(_isBattleActive):
		_calculateNextTurn()		
	pass

func _setCurrentTurn(turn):
	_currentTurn = turn
	pass

func _calculateNextTurn():
	var maxSpeedEnemy = _enemyParty.findMaxBattleSpeedMember()
	var maxSpeedPlayer = _playerParty.findMaxBattleSpeedMember()

	var enemySpeed = maxSpeedEnemy.getStats().getActiveSpeed()
	var playerSpeed = maxSpeedPlayer.getStats().getActiveSpeed()
	var numSpeedSteps = 0

	if enemySpeed > playerSpeed:
		numSpeedSteps = GameConsts.MAX_BATTLE_SPEED - enemySpeed
		_setCurrentTurn(Turn.ENEMY)
	else:
		numSpeedSteps = GameConsts.MAX_BATTLE_SPEED - playerSpeed
		_setCurrentTurn(Turn.PLAYER)
	
	_enemyParty.addActiveSpeed(numSpeedSteps)
	_playerParty.addActiveSpeed(numSpeedSteps)
	if _currentTurn == Turn.PLAYER:
		_playerParty.setHasTurn(maxSpeedPlayer)
		maxSpeedPlayer.getStats().resetActiveSpeed()
	else:
		_enemyParty.setHasTurn(maxSpeedEnemy)
		maxSpeedEnemy.getStats().resetActiveSpeed()
	pass

func _onFinishedTurn():
	if _isBattleActive and _enemyParty != null:
		finishTurn()
	pass

func _partyLost(partyType):
	match partyType:
		GameConsts.PartyType.PLAYER:
			_endBattle(false)
		GameConsts.PartyType.ENEMY:
			_endBattle(true)
	pass
	
func _endBattle(var shouldGiveLoot):

	var lootArray = null
	if(shouldGiveLoot):
		lootArray = _calculateLoot()
				
	_playerParty.onBattleEnded(lootArray)
	_enemyParty.onBattleEnded()
	_enemyParty.queue_free() # This is how you release instanced script memory
	_enemyParty = null
	_isBattleActive = false
	pass

func _getRandomTurn():
	randomize()
	var turn = randi() % 2 # Random value 0 or 1
	return turn
	
func _calculateLoot():	
	var loot = []
	var table = _enemyParty.getLootTable()
	
	for lootEntryTemplate in table:
		var lootEntry = lootEntryTemplate.instance()
		var itemId = lootEntry.getItemId()
		if !_playerParty.hasItem(itemId):
			var probability = lootEntry.getProbability()
			if(Utils.isChanceHit(probability)):
				loot.append(lootEntry.getItemId())
	return loot
