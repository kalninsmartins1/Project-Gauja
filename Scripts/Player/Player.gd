extends KinematicBody

# Member variables
export(PackedScene) var _profileTemplate
export var _maxSpeed = 10
export var _manaRecharge = 10
export var _healthRecharge = 10
export var _potionRechargeTime = 1.5

onready var _playerParty = get_parent().get_parent()
onready var _animationTree = get_node("AnimationTreePlayer")
onready var _tween = get_node("PlayerUI/Tween")

var _id = -1
var _health = 100
var _maxHealth = 100
var _mana = 100
var _maxMana = 100
var _respawnPosition = null
var _isAttackFinished = true
var _isInBattle = false
var _direction = Vector3(0, 0, 0)
var _fallowTarget = null
var _fallowDistance = 0
var _isFallowing = false

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

func getProfileTemplate():
	return _profileTemplate	

func getId():
	return _id

func setId(id):
	_id = id
	pass

func setIsInBattle(isInBattle):
	_isInBattle = _isInBattle
	pass

func setMoveDirection(direction):
	_direction = direction
	pass

func setRespawnPosition(position):
	_respawnPosition = position
	pass

func startFallow(fallowTarget, fallowDistance):
	_fallowTarget = fallowTarget
	_fallowDistance = fallowDistance
	_isFallowing = true
	pass

func stopFallow():
	_fallowTarget = null
	_fallowDistance = 0
	_isFallowing = false
	pass

func lookAt(position):
	look_at(position, GameConsts.VECTOR3_UP)
	pass

func takeDamage(damage):
	_health -= damage
	clamp(_health, 0, _maxHealth)	
	emit_signal("onHealthChanged", _health)
	
	if(_health == 0):
		_respawn()
	pass

func castSkill(skillId):
	if(_isAttackFinished):		
		match(skillId):
			GameConsts.Skill.FIRE_BALL:
				var target = _playerParty.getTarget()
				_shootFireball(target)
			GameConsts.Skill.POTION_HP:
				_addHealth(_healthRecharge)
				_tween.interpolate_callback(self, _potionRechargeTime, "_onPotionRechargeFinished")
			GameConsts.Skill.POTION_MP:
				_addMana(_manaRecharge)
				_tween.interpolate_callback(self, _potionRechargeTime, "_onPotionRechargeFinished")
				
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
	
	if(_isFallowing):
		var toTarget = (_fallowTarget.translation - translation)
		var distanceToTargetSqr = toTarget.length_squared()
		if distanceToTargetSqr > _fallowDistance*_fallowDistance:
			_direction = toTarget
		else:
			_direction = Vector3(0, 0, 0)

	var currentAnim = _animationTree.transition_node_get_current(GameConsts.ANIM_TRANSITION_NODE)
	if(_isMoving(_direction) and !_isInBattle):
		# Face the movement direction
		look_at(get_global_transform().origin + _direction, GameConsts.VECTOR3_UP)

		# Move player in direction and collide
		move_and_collide(_direction.normalized() * _maxSpeed * delta)

		if(currentAnim != GameConsts.ANIM_WALK_ID):
			_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_WALK_ID)
	elif(currentAnim != GameConsts.ANIM_IDLE_ID):
		# Play idle animation
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_IDLE_ID)
	pass
	





