extends Node

export(Array) var _playerTemplates
export var _fallowDistance = 5

onready var _playerContainer = get_node("PlayerList")
onready var _itemDatabase = get_node("../ItemDatabase")
onready var _battleManager = get_node("../BattleManager")
onready var _navigationManager = get_node("../Navigation")
onready var _playerUI = get_node("PlayerUI")

var _playerList = []
var _inventory = []
var _activePlayer = null
var _isInBattle = false
var _hasTurn = false
var _enemy = null
var _waitingForPlayers = []

signal onInventoryChanged
signal onRequestInventoryOpen
signal onBattleStarted
signal onBattleEnded
signal onActivePlayerSwitched
signal onTurnFinished

func isInBattle():
	return _isInBattle
	
func setHasTurn(hasTurn):
	_hasTurn = hasTurn
	pass

func getTarget():
	return _battleManager.getTarget()

func getInventory():
	return _inventory

func getItemDatabase():
	return _itemDatabase

func getActivePlayer():
	return _activePlayer

func battleStarted(enemy):
	_isInBattle = true
	_enemy = enemy
	
	_preparePlayersForBattle()
	pass
	
func battleEnded(loot):
	_isInBattle = false
	_enemy = null
	if(loot != null):
		emit_signal("onLootReceived", loot)
		for itemId in loot:
			_addInventoryItem(itemId)
		emit_signal("onInventoryChanged")
	emit_signal("onBattleEnded")
	pass

func _ready():
	_initPlayers()
	_itemDatabase.connect("onItemDatabaseInitialized", self, "_onItemDatabaseInitialized")
	
	pass
	
func _preparePlayersForBattle():
	_activePlayer.lookAt(_enemy.get_global_transform().origin)
	_activePlayer.setMoveDirection(Vector3(0, 0, 0))
	
	if _playerList.size() == 1:
		emit_signal("onBattleStarted")
	else:
		var activePlayerTransform = _activePlayer.get_global_transform()	
		var activePlayerPosition = activePlayerTransform.origin	
		var leftPosition = activePlayerPosition - activePlayerTransform.basis.x * _fallowDistance
		var rightPosition = activePlayerPosition + activePlayerTransform.basis.x * _fallowDistance
		var availablePositions = [leftPosition, rightPosition]
		
		var index = 0
		for player in _playerList:
			var playerId = player.getId()
			if playerId != _activePlayer.getId():
				var path = _navigationManager.get_simple_path(player.get_global_transform().origin, availablePositions[index])				
				player.stopFallow()
				player.moveToPosition(path)
				_waitingForPlayers.append(playerId)
				index += 1
	pass

func _onItemDatabaseInitialized():
	# For testing purposes
	for itemId in _itemDatabase.getItemIdList():
		_addInventoryItem(itemId)
	emit_signal("onInventoryChanged")	
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
		
		_playerContainer.add_child(player)
		_playerList.append(player)
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

func _playerFinishedTurn(player):
	emit_signal("onTurnFinished")
	pass
	
func _onPlayerReachedPosition(player):
	if _isInBattle:
		player.lookAt(_enemy.get_global_transform().origin)
		_waitingForPlayers.erase(player.getId())
		if _waitingForPlayers.size() == 0:
			emit_signal("onBattleStarted")
	pass

func _onActivePlayerSwitchRequest(playerId):
	if !_isInBattle:
		var inactivePlayerList = []
		
		# Set new active player
		for player in _playerList:
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
		
		# Notify UI that active player has changed
		_playerUI.onActivePlayerChanged(playerId)
		emit_signal("onActivePlayerSwitched")
	pass

func _process(delta):
	_handleInput()
	pass
	
func _handleInput():	
	if(Input.is_action_just_released("open_inventory")):
		emit_signal("onRequestInventoryOpen")

	# Handle battle skills
	if(_hasTurn):
		if(Input.is_action_just_released("skill_1")):
			_activePlayer.castSkill(GameConsts.Skill.FIRE_BALL)
		elif(Input.is_action_just_released("skill_9")):
			_activePlayer.castSkill(GameConsts.Skill.POTION_HP)
		elif(Input.is_action_just_released("skill_0")):
			_activePlayer.castSkill(GameConsts.Skill.POTION_MP)

	if !_isInBattle:
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
