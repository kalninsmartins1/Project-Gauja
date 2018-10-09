extends KinematicBody

# Member variables
export var _maxSpeed = 10
export var _manaRecharge = 10
export var _healthRecharge = 10
export var _potionRechargeTime = 1.5

onready var _animationTree = get_node("AnimationTreePlayer")
onready var _itemDatabase = get_node("../ItemDatabase")
onready var _battleManager = get_node("../BattleManager")
onready var _tween = get_node("PlayerUI/Tween")

var _isInBattle = false
var _upVector = Vector3(0, 1, 0)
var _health = 100
var _maxHealth = 100
var _mana = 100
var _maxMana = 100
var _respawnPosition = null
var _isAttackFinished = true
var _hasTurn = false
var _inventory = []

# Signals
signal onHealthChanged
signal onManaChanged
signal onLootReceived
signal onTurnFinished
signal onInventoryChanged
signal onRequestInventoryOpen
signal onBattleStarted
signal onBattleEnded

# Public functions

func getInventory():
	return _inventory

func getItemDatabase():
	return _itemDatabase

func isInBattle():
	return _isInBattle
	
func setHasTurn(hasTurn):
	_hasTurn = hasTurn
	pass
	
func setRespawnPosition(position):
	_respawnPosition = position
	pass
	
func battleStarted(enemy):
	_isInBattle = true
	look_at(enemy.translation, _upVector)
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

func _addMana(amount):
	_mana += amount
	_mana = clamp(_mana, 0, _maxMana)
	emit_signal("onManaChanged", _mana)
	pass

func _addHealth(amount):
	_health += amount
	_health = clamp(_health, 0, _maxHealth)
	emit_signal("onHealthChanged", _health)
	pass

func _addInventoryItem(itemId):
	_inventory.append(itemId)	
	pass

func _castSkill(skillId):
	if(_isAttackFinished):		
		match(skillId):
			GameConsts.Skill.FIRE_BALL:
				var target = _battleManager.getTarget()
				_shootFireball(target)
			GameConsts.Skill.POTION_HP:
				_addHealth(_healthRecharge)
				_tween.interpolate_callback(self, _potionRechargeTime, "_onPotionRechargeFinished")
			GameConsts.Skill.POTION_MP:
				_addMana(_manaRecharge)
				_tween.interpolate_callback(self, _potionRechargeTime, "_onPotionRechargeFinished")
				
	pass

func _onPotionRechargeFinished():
	emit_signal("onTurnFinished")
	pass

func _shootFireball(target):
	var fireball = preload("res://Scenes/fireball.scn").instance()
	var hasEnoughMana = _consumeMana(fireball.getManaConsumption())	
	if(hasEnoughMana):		
		var shootPosition = get_node("Armature/shootPosition").get_global_transform()
		fireball.set_transform(shootPosition.orthonormalized())
		fireball.connect("onDestroyed", self, "_attackFinished")
		get_parent().add_child(fireball)
	
		var toTarget = target.translation - shootPosition.origin
		fireball.set_linear_velocity(toTarget.normalized() * fireball.getShootSpeed())
		fireball.add_collision_exception_with(self)
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_ATTACK_ID)
		_isAttackFinished = false
	pass

func _attackFinished():
	emit_signal("onTurnFinished")
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
	_animationTree.set_active(true)
	pass

func _physics_process(delta):

	# Get input - All the input probably need to be extracted to its own fuction
	var direction = _handleInput()	 			
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
			
	pass
	
func _handleInput():	
	if(Input.is_action_just_released("open_inventory")):
		emit_signal("onRequestInventoryOpen")

	# Handle battle skills
	if(_hasTurn):
		if(Input.is_action_just_released("skill_1")):
			_castSkill(GameConsts.Skill.FIRE_BALL)
		elif(Input.is_action_just_released("skill_9")):
			_castSkill(GameConsts.Skill.POTION_HP)
		elif(Input.is_action_just_released("skill_0")):
			_castSkill(GameConsts.Skill.POTION_MP)

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
			
	return direction




