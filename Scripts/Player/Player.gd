extends KinematicBody

# Member variables
export(PackedScene) var _profileTemplate
export var _maxSpeed = 10
export var _manaRecharge = 10
export var _healthRecharge = 10
export var _potionRechargeTime = 1.5

onready var _playerParty = get_parent().get_parent()
onready var _animationTree = get_node("AnimationTreePlayer")
onready var _tween = get_node("Tween")
onready var _stats = get_node("PlayerStats")

var _id = -1
var _respawnPosition = null
var _isTurnFinished = true
var _isInBattle = false
var _direction = Vector3(0, 0, 0)
var _fallowTarget = null
var _fallowDistance = 0
var _isFallowing = false

# -1 means no item in slot
# First 2 slots are not used
var _equipedItemIds = [-1, -1, -1, -1, -1, -1, -1]
var _aiPath = null
var _isMovingToPosition = false

# Signals
signal onHealthChanged
signal onManaChanged
signal onTurnFinished
signal onMovePositionReached

# Public functions

func isAlive():
	return _stats.isAlive()

func getProfileTemplate():
	return _profileTemplate	

func getId():
	return _id
	
func getEquipedItemId(itemType):
	return _equipedItemIds[itemType]

func setEquipedItemId(item):
	_equipedItemIds[item.getItemType()] = item.getId()
	pass

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
	
func moveToPosition(path):
	_aiPath = path
	_isMovingToPosition = true
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

func respawn():
	translation = _respawnPosition
	revive()
	pass

func lookAt(position):
	look_at(position, GameConsts.VECTOR3_UP)
	pass

func revive():
	set_visible(true)
	_stats.revive()
	pass

func takeDamage(damage):
	_stats.takeDamage(damage)

	if !_stats.isAlive():
		_despawn()
	pass

func castSkill(skillId):
	if(_isTurnFinished):
		match(skillId):
			GameConsts.Skill.FIRE_BALL:
				var target = _playerParty.getActiveEnemy()
				_shootFireball(target)
			GameConsts.Skill.POTION_HP:
				_stats.healHealth(_healthRecharge)
				_tween.interpolate_callback(self, _potionRechargeTime, "_onPotionRechargeFinished")
				_tween.start()
				_isTurnFinished = false
			GameConsts.Skill.POTION_MP:
				_stats.healMana(_manaRecharge)
				_tween.interpolate_callback(self, _potionRechargeTime, "_onPotionRechargeFinished")
				_tween.start()
				_isTurnFinished = false				
	pass

func _isMoving(direction):
	return direction.length_squared() > 0
	
func _despawn():
	set_visible(false)
	_stats.consumeMana(_stats.getMana())	
	pass
	
func _moveTowardsPosition(targetPosition, maxDistance):	
	var curPosition = get_global_transform().origin
	var toTarget = targetPosition - curPosition
	var hasArrived = false
	var lengthSquared = toTarget.length_squared()
	if toTarget.length_squared() > maxDistance*maxDistance:
		_direction = toTarget
	else:
		_direction = Vector3(0, 0, 0)
		hasArrived = true
		
	return hasArrived

func _onPotionRechargeFinished():
	_isTurnFinished = true
	emit_signal("onTurnFinished", self)
	pass

func _shootFireball(target):
	var fireball = preload("res://Scenes/fireball.scn").instance()
	var hasEnoughMana = _stats.consumeMana(fireball.getManaConsumption())	
	if(hasEnoughMana):
		var startTransform = get_node("Armature/shootPosition").get_global_transform()
		fireball.set_global_transform(startTransform)
		fireball.connect("onDestroyed", self, "_attackFinished")
		_playerParty.get_parent().add_child(fireball)
	
		var toTarget = target.get_global_transform().origin - startTransform.origin
		fireball.set_linear_velocity(toTarget.normalized() * fireball.getShootSpeed())
		fireball.add_collision_exception_with(self)
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_ATTACK_ID)
		_isTurnFinished = false
	pass

func _attackFinished():
	emit_signal("onTurnFinished", self)
	_isTurnFinished = true
	pass

func _ready():	
	_animationTree.set_active(true)
	_stats.connect("onHealthChanged", self, "_onHealthChanged")
	_stats.connect("onManaChanged", self, "_onManaChanged")
	pass

func _onHealthChanged(newAmount, delta):
	emit_signal("onHealthChanged", newAmount, delta)
	pass

func _onManaChanged(newAmount, delta):
	emit_signal("onManaChanged", newAmount, delta)
	pass
	
func _finishedMovingToPosition():
	_aiPath = null	
	_isMovingToPosition = false
	emit_signal("onMovePositionReached", self)
	pass

func _physics_process(delta):
	
	if _isFallowing:
		_moveTowardsPosition(_fallowTarget.get_global_transform().origin, _fallowDistance)		
			
	if _isMovingToPosition and _aiPath.size() > 0:
		if _moveTowardsPosition(_aiPath[0], 0.5):
			_aiPath.remove(0)
		
		if _aiPath.size() == 0:
			_finishedMovingToPosition()

	var currentAnim = _animationTree.transition_node_get_current(GameConsts.ANIM_TRANSITION_NODE)
	if _isMoving(_direction) and !_isInBattle:
		# Face the movement direction
		look_at(get_global_transform().origin + _direction, GameConsts.VECTOR3_UP)

		# Move player in direction and collide
		move_and_collide(_direction.normalized() * _maxSpeed * delta)

		if currentAnim != GameConsts.ANIM_WALK_ID:
			_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_WALK_ID)
	elif currentAnim != GameConsts.ANIM_IDLE_ID:
		# Play idle animation
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_IDLE_ID)
	pass
	
	
	





