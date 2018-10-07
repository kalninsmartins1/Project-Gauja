extends KinematicBody

# Member variables
export var _maxSpeed = 10
export var _manaReloadSpeed = 20

var _animationTree;
var _isInBattle = false
var _upVector = Vector3(0, 1, 0)
var _health = 100
var _maxHealth = 100
var _mana = 100
var _maxMana = 100
var _tween = null
var _respawnPosition = null
var _itemDatabase = null
var _isAttackFinished = true
var _inventory = []

# Signals
signal onHealthChanged
signal onManaChanged
signal onLootReceived
signal onAttackFinished
signal onInventoryChanged
signal onRequestInventoryOpen

# Public functions

func getInventory():
	return _inventory

func getItemDatabase():
	return _itemDatabase

func isInBattle():
	return _isInBattle
	pass
	
func setRespawnPosition(position):
	_respawnPosition = position
	pass

func attack(target, skill):
	
	if(_isAttackFinished):		
		match(skill):
			GameConsts.Skill.FIRE_BALL:
				_shootFireball(target)
	pass
	
func battleStarted(enemy):
	_isInBattle = true
	look_at(enemy.translation, _upVector)
	pass
	
func battleEnded(loot):
	_isInBattle = false
	if(loot != null):
		emit_signal("onLootReceived", loot)
		for itemId in loot:
			_addInventoryItem(itemId)
		emit_signal("onInventoryChanged")
	pass

func takeDamage(damage):
	_health -= damage
	clamp(_health, 0, _maxHealth)	
	emit_signal("onHealthChanged", _health)
	
	if(_health == 0):
		_respawn()
	pass

func _consumeMana(amount):
	var hasEnoughMana = amount < _mana
	if(hasEnoughMana):
		_mana -= amount
		_mana = clamp(_mana, 0, _maxMana)
		emit_signal("onManaChanged", _mana)
	return hasEnoughMana

func _addInventoryItem(itemId):
	_inventory.append(itemId)	
	pass

func _shootFireball(target):
	var fireball = preload("res://Scenes/fireball.scn").instance()
	var hasEnoughMana = _consumeMana(fireball.getManaConsumption())	
	if(hasEnoughMana):		
		var shootPosition = get_node("Armature/shootPosition").get_global_transform()
		fireball.set_transform(shootPosition.orthonormalized())
		fireball.connect("onDestroyed", self, "_onAttackFinished")
		get_parent().add_child(fireball)
	
		var toTarget = target.translation - shootPosition.origin
		fireball.set_linear_velocity(toTarget.normalized() * fireball.getShootSpeed())
		fireball.add_collision_exception_with(self)
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_ATTACK_ID)		
		_isAttackFinished = false
	pass

func _onAttackFinished():
	emit_signal("onAttackFinished")
	_isAttackFinished = true
	pass

func _isMoving(direction):
	return direction.length_squared() > 0
	
func _respawn():
	translation = _respawnPosition
	_health = _maxHealth
	_mana = _maxMana
	
	emit_signal("onHealthChanged", _health)
	emit_signal("onManaChanged", _mana)
	pass

func _ready():
	_animationTree = get_node(GameConsts.ANIMTION_TREE_PLAYER)
	_animationTree.set_active(true)
	
	_itemDatabase = get_node("../ItemDatabase")
	pass

func _physics_process(delta):
	var direction = Vector3() # Where does the player intend to walk to
	var forward = Vector3(0, 0, 1)

	# Get input - All the input probably need to be extracted to its own fuction
	if (Input.is_action_pressed("move_forward")):
		direction += -forward
	if (Input.is_action_pressed("move_backwards")):
		direction += forward
	if (Input.is_action_pressed("move_left")):
		direction += Vector3(-1, 0, 0)
	if (Input.is_action_pressed("move_right")):
		direction += Vector3(1, 0, 0)
	
	if(Input.is_action_just_released("open_inventory")):
		emit_signal("onRequestInventoryOpen")
		
	var currentAnim = _animationTree.transition_node_get_current(GameConsts.ANIM_TRANSITION_NODE)

	if(_isMoving(direction) and !_isInBattle):
		# Face the movement direction
		look_at(translation + direction, _upVector)

		# Move player in direction and collide
		move_and_collide(direction.normalized() * _maxSpeed * delta)

		if(currentAnim != GameConsts.ANIM_WALK_ID):
			_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_WALK_ID)
	elif(currentAnim != GameConsts.ANIM_IDLE_ID):
		# Play animation
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_IDLE_ID)
		
	_handleManaRecharge(delta)
	pass
		
func _handleManaRecharge(deltaTime):
	if(_mana < _maxMana):
		_mana += _manaReloadSpeed * deltaTime
		if(_mana > _maxMana):
			_mana = _maxMana
		emit_signal("onManaChanged", _mana)
	pass




