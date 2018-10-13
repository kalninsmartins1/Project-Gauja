extends Node

export(PackedScene) var _playerTemplate
export var _fallowDistance = 5

onready var _playerContainer = get_node("PlayerList")
onready var _itemDatabase = get_node("../ItemDatabase")
onready var _battleManager = get_node("../BattleManager")

var _playerList = []
var _inventory = []
var _activePlayer = null
var _isInBattle = false
var _hasTurn = false

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
	for player in _playerList:
		player.lookAt(enemy.translation)	
	emit_signal("onBattleStarted")
	pass
	
func battleEnded(loot):
	_isInBattle = false
	if(loot != null):
		emit_signal("onLootReceived", loot)
		for itemId in loot:
			_addInventoryItem(itemId)
		emit_signal("onInventoryChanged")
	emit_signal("onBattleEnded")
	pass

func _ready():
	_initPlayers()	
	pass

func _addInventoryItem(itemId):
	_inventory.append(itemId)	
	pass

func _initPlayers():
	var _previousPlayer = null
	for index in range(0, GameConsts.MAX_PARTY_COUNT):
		var player = _playerTemplate.instance()
		_playerContainer.add_child(player)
		_playerList.append(player)
		if index == 0:
			_activePlayer = player
		else:
			player.startFallow(_previousPlayer, _fallowDistance)
		_previousPlayer = player
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
