extends "res://Scripts/Party.gd"

export(Array) var _playerTemplates
export var _fallowDistance = 5
export var _respawnTime = 2

onready var _playerContainer = get_node("PlayerList")
onready var _itemDatabase = get_node("../ItemDatabase")
onready var _battleManager = get_node("../BattleManager")
onready var _navigationManager = get_node("../Navigation")
onready var _playerUI = get_node("PlayerUI")
onready var _tween = get_node("PlayerUI/Tween")

var _players = null
var _inventory = []
var _activePlayer = null
var _isInBattle = false
var _hasTurn = false
var _waitingForPlayers = []

signal onInventoryChanged
signal onRequestInventoryOpen
signal onBattleStarted
signal onBattleEnded
signal onActivePlayerSwitched
signal onTurnFinished
signal onLootReceived
signal onPartyLost

func getActiveEnemy():
	return _battleManager.getActiveEnemy()

func getPartyType():
	return GameConsts.PartyType.PLAYER
	
func isInBattle():
	return _isInBattle

func hasItem(itemId):
	return _inventory.has(itemId)	

func getTarget():
	return _battleManager.getTarget()

func getInventory():
	return _inventory

func getItemDatabase():
	return _itemDatabase

func getActivePlayer():
	return _activePlayer

func findClosestPlayer(position):
	var minDistance = INF
	var keyPlayer = null
	for player in _players:
		var distSq = (position - player.get_global_transform().origin).length_squared()
		if distSq < minDistance:
			minDistance = distSq
			keyPlayer = player
	return keyPlayer

func onHasTurn(player):
	_hasTurn = true
	_setActivePlayer(player)		
	pass

func onBattleStarted(enemy):
	_isInBattle = true	
	
	_preparePlayersForBattle(enemy)
	pass

func onTurnChanged():
	if !_activePlayer.isAlive():
		_activePlayer = findMaxBattleSpeedMember()
	pass
	
func onBattleEnded(hasWon, loot):
	_isInBattle = false
	_hasTurn = false
	
	if hasWon:
		_reviveNotAlivePartyMembers()

	if(loot != null):
		emit_signal("onLootReceived", loot)
		for itemId in loot:
			_addInventoryItem(itemId)
		emit_signal("onInventoryChanged")
	emit_signal("onBattleEnded")	
	_startFallowingActivePlayer(_activePlayer.getId())
	pass

func _isAnyAlive():
	var aliveCount = 0
	for player in _players:
		if player.isAlive():
			aliveCount += 1
	return aliveCount > 0

func _setActivePlayer(player):
	_activePlayer = player

	# Notify UI that active player has changed
	_playerUI.onActivePlayerChanged(player.getId())
	emit_signal("onActivePlayerSwitched")
	pass

func _findPlayerById(playerId):
	var keyPlayer = null
	for player in _players:
		if player.getId() == playerId:
			keyPlayer = player
	return keyPlayer

func _ready():
	_players = getMembers()
	_initPlayers()
	pass
	
func _preparePlayersForBattle(enemy):	
	_activePlayer.lookAt(enemy.get_global_transform().origin)
	_activePlayer.setMoveDirection(Vector3(0, 0, 0))
	
	if _players.size() == 1:
		emit_signal("onBattleStarted")
	else:
		var activePlayerTransform = _activePlayer.get_global_transform()	
		var activePlayerPosition = activePlayerTransform.origin	
		var leftPosition = activePlayerPosition - activePlayerTransform.basis.x * _fallowDistance
		var rightPosition = activePlayerPosition + activePlayerTransform.basis.x * _fallowDistance
		var availablePositions = [leftPosition, rightPosition]
		
		var index = 0
		for player in _players:
			var playerId = player.getId()
			if playerId != _activePlayer.getId():
				var path = _navigationManager.get_simple_path(player.get_global_transform().origin, availablePositions[index])				
				player.stopFallow()
				player.moveToPosition(path)
				_waitingForPlayers.append(playerId)
				index += 1
	pass

func _reviveNotAlivePartyMembers():
	for player in _players:
		if !player.isAlive():
			player.revive()
	pass

func _addInventoryItem(itemId):
	_inventory.append(itemId)
	pass

func _initPlayers():
	var _previousPlayer = null
	var index = 0
	
	for playerTemplate in _playerTemplates:
		var player = playerTemplate.instance()
		player.setId(index)
		player.connect("onMovePositionReached", self, "_onPlayerReachedPosition")
		player.connect("onTurnFinished", self, "_playerFinishedTurn")
		player.connect("onHealthChanged", self, "_onPlayerHealthChanged")
		_playerContainer.add_child(player)
		_players.append(player)
		_playerUI.addCharacterProfile(player)
		_playerUI.connect("onActivePlayerSwitchRequest", self, "_onActivePlayerSwitchRequest")
		
		if index == 0:
			_activePlayer = player
			_playerUI.onActivePlayerChanged(player.getId())
		else:
			player.startFallow(_previousPlayer, _fallowDistance)
		_previousPlayer = player
		
		index += 1
	pass

func _onPlayerHealthChanged(health, delta):
	if health <= 0:		
		if !_isAnyAlive():
			emit_signal("onPartyLost", getPartyType())
			_tween.interpolate_callback(self, _respawnTime, "_respawnParty")
			_tween.start()
	pass

func _respawnParty():
	for player in _players:
		player.respawn()
	pass

func _startFallowingActivePlayer(playerId):
	var inactivePlayerList = []
		
	# Set new active player
	for player in _players:
		if player.getId() == playerId:
			_activePlayer = player
			player.stopFallow()
		else:
			inactivePlayerList.append(player)
	
	# Make inactive players fallow the new active player
	var previousPlayer = null
	for player in inactivePlayerList:
		if previousPlayer == null:
			player.startFallow(_activePlayer, _fallowDistance)
		else:
			player.startFallow(previousPlayer, _fallowDistance)
		
		previousPlayer = player
	pass

func _playerFinishedTurn(player):
	if _isInBattle:
		emit_signal("onTurnFinished")		
	pass
	
func _onPlayerReachedPosition(player):
	if _isInBattle:
		var enemy = _battleManager.getActiveEnemy()
		player.lookAt(enemy.get_global_transform().origin)
		_waitingForPlayers.erase(player.getId())
		if _waitingForPlayers.size() == 0:
			emit_signal("onBattleStarted")
	pass

func _onActivePlayerSwitchRequest(playerId):
	if !_isInBattle:
		_startFallowingActivePlayer(playerId)
		var newActivePlayer = _findPlayerById(playerId)
		_setActivePlayer(newActivePlayer)		
	pass

func _process(delta):
	_handleInput()
	pass
	
func _handleInput():	

	# Handle battle skills
	if(_hasTurn):
		if(Input.is_action_just_released("skill_1")):
			_activePlayer.castSkill(GameConsts.Skill.FIRE_BALL)
		elif(Input.is_action_just_released("skill_9")):
			_activePlayer.castSkill(GameConsts.Skill.POTION_HP)
		elif(Input.is_action_just_released("skill_0")):
			_activePlayer.castSkill(GameConsts.Skill.POTION_MP)

	if !_isInBattle:
		
		if(Input.is_action_just_released("open_inventory")):
			emit_signal("onRequestInventoryOpen")
		
		# Handle character movement
		var direction = Vector3(0, 0, 0)
		var forward = Vector3(0, 0, 1)
		
		if (Input.is_action_pressed("move_forward")):
			direction += -forward
		if (Input.is_action_pressed("move_backwards")):
			direction += forward
		if (Input.is_action_pressed("move_left")):
			direction += Vector3(-1, 0, 0)
		if (Input.is_action_pressed("move_right")):
			direction += Vector3(1, 0, 0)
		
		_activePlayer.setMoveDirection(direction)
	pass
