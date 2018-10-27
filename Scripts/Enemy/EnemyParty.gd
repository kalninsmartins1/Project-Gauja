extends Node

const _distanceBetweenEnemies = 5

var _enemies = []

var _battleManager = null
var _lootTable = null
var _leftPosition = null
var _rightPosition = null

var _activeIndex = 0
var _hasTurn = false
var _isLeftPositionFree = true

signal onTurnFinished
signal onPartyLost

func getLootTable():
	return _lootTable

func hasTurn():
	return _hasTurn

func getPartyType():
	return GameConsts.PartyType.ENEMY

func getActiveEnemy():
	return _enemies[_activeIndex]    

func isPartyFull():
	return _enemies.size() > GameConsts.MAX_PARTY_COUNT

func setHasTurn(hasTurn):
	_hasTurn = hasTurn
	if _enemies.size() > 0:
		_enemies[_activeIndex].setHasTurn(hasTurn)
	pass

func onBattleStarted(battleManager):
	_battleManager = battleManager
	pass

func onBattleEnded():
	for enemy in _enemies:
		enemy.onBattleEnded()
	pass

func addEnemy(enemy):
	_enemies.append(enemy)
	enemy.connect("onTurnFinished", self, "_onTurnFinished")
	enemy.connect("onHealthChanged", self, "_onHealthChanged") 
	if _enemies.size() > 1:
		_moveToFreeBattlePosition(enemy) # This is not the first enemy
		enemy.connect("onDestinationReached", self, "_onBattlePositionReached")
	else:
		_initBattlePositions()
		_onBattlePositionReached(enemy)
	pass

func _isAnyAlive():
	var aliveCount = 0
	for enemy in _enemies:
		if enemy.isAlive():
			aliveCount += 1
	return aliveCount > 0

func _setNextActiveEnemy():
	var numEnemies = _enemies.size()
	if numEnemies > 1:	
		_activeIndex = Utils.getRandIntegerValInRange(0, numEnemies, _activeIndex)
	else:
		_activeIndex = 0
	pass

func _onBattlePositionReached(enemy):
	enemy.playIdleAnimation()

	var playerPos = _battleManager.getActivePlayer().get_global_transform().origin
	var enemyPos = enemy.get_global_transform().origin
	var toPlayer = playerPos - enemyPos
	enemy.startRotationTween(Vector2(toPlayer.x, toPlayer.z).normalized())
	enemy.setCurPosAsBattlePos()

	# This signal should be called only once per battle per enemy
	enemy.disconnect("onDestinationReached", self, "_onBattlePositionReached")
	pass

func _initBattlePositions():
	var activeEnemyTransform = _enemies[_activeIndex].get_global_transform()	
	var activeEnemyPosition = activeEnemyTransform.origin	
	
	_leftPosition = activeEnemyPosition - activeEnemyTransform.basis.x * _distanceBetweenEnemies
	_rightPosition = activeEnemyPosition + activeEnemyTransform.basis.x * _distanceBetweenEnemies
	pass

func _moveToFreeBattlePosition(enemy):	
	if _isLeftPositionFree:
		enemy.setDestination(_leftPosition)
		_isLeftPositionFree = false
	else:
		enemy.setDestination(_rightPosition)
	pass

func _onTurnFinished():
	emit_signal("onTurnFinished")
	_setNextActiveEnemy()
	pass

func _onHealthChanged(enemy):
	if !enemy.isAlive():		
		_enemies.erase(enemy)
		_setNextActiveEnemy()
		if !_isAnyAlive():
			_lootTable = enemy.getLootTable()
			emit_signal("onPartyLost", getPartyType())	
	pass