extends "res://Scripts/Party.gd"

const _distanceBetweenEnemies = 3

var _enemies = null
var _battleManager = null
var _lootTable = null
var _leftPosition = null
var _rightPosition = null

var _activeIndex = 0
var _hasTurn = false
var _isLeftPositionFree = true
var _isBattlePositionsSet = false

signal onTurnFinished
signal onPartyLost

func IsBattlePositionsSet():
	return _isBattlePositionsSet

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

func onHasTurn(enemy):
	_hasTurn = true
	enemy.setHasTurn(true)
	var enemyIndex = _enemies.find(enemy)
	_activeIndex = enemyIndex
	pass

func onBattleStarted(battleManager):
	_battleManager = battleManager
	_enemies = getMembers()
	pass

func onBattleEnded(hasWon):
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
		enemy.connect("onFinishedRotating", self, "_onEnemyFinishedRotating")
		_onBattlePositionReached(enemy)
	pass

func _isAnyAlive():
	var aliveCount = 0
	for enemy in _enemies:
		if enemy.isAlive():
			aliveCount += 1
	return aliveCount > 0

func _onEnemyFinishedRotating(enemy):
	_initBattlePositions()
	enemy.disconnect("onFinishedRotating", self, "_onEnemyFinishedRotating")
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
	_isBattlePositionsSet = true
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
	pass

func _removeNotAliveEnemies():
	var notAliveIndexes= []
	var index = 0
	for enemy in _enemies:
		if !enemy.isAlive():
			notAliveIndexes.append(index)
		index += 1

	for removeIndex in notAliveIndexes:
		_enemies.remove(removeIndex)
	pass


func _onHealthChanged(health, delta):
	if health <= 0:
		if _enemies.size() == 1:
			_lootTable = _enemies[0].getLootTable()
			emit_signal("onPartyLost", getPartyType())

		_removeNotAliveEnemies()
	pass