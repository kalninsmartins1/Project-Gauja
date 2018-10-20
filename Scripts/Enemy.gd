extends RigidBody

# Export vars
export(Array) var _lootTable
export var _moveSpeed = 20.0
export var _rotationSpeed = 20.0
export var _activeRadius = 100.0
export var _battleRadius = 10
export var _health = 100.0
export var _damage = 10.0

# Private vars for this script usage only
onready var _navigationManager = get_node("../Navigation")
onready var _playerParty = get_node("../PlayerParty")
onready var _tweener = get_node("Tween")
onready var _animationTree = get_node("AnimationTreePlayer")
onready var _battleManager = get_node("../BattleManager")
onready var _camera = get_node("../Camera")
onready var _healthBar = get_node("TextureProgress")

var _curPath = null
var _battlePosition = null
var _curIndex = 0
var _currentAngle = 0

var _isMoving = false
var _isTweenActive = false
var _isInBattle = false
var _hasTurn = false
var _isCurrentlyAttacking = false
var _isTakingDamage = false

# Public Interface
	
	# Signals

signal onTurnFinished
signal onHealthChanged

	# Functions

func getLootTable():
	return _lootTable

func isCurrentlyAttacking():
	return _isCurrentlyAttacking
	
func isTakingDamage():
	return _isTakingDamage

func getBattlePosition():
	return _battlePosition

func getPlayer():
	return _playerParty.getActivePlayer()

func hasTurn():
	return _hasTurn

func getActiveRadius():
	return _activeRadius	

func getAttackAnimLength():
	var animName = _animationTree.node_get_input_source(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_ATTACK_ID)
	var animation = _animationTree.animation_node_get_animation(animName)
	return animation.length

func isMoving():
	return _isMoving	

func isInBattle():
	return _isInBattle
	
func isAlive():
	return _health > 0

func setIsTakingDamage(value):
	_isTakingDamage = value
	pass

func setIsCurrentlyAttacking(value):
	_isCurrentlyAttacking = value
	pass

func setHasTurn(value):
	_hasTurn = value
	pass

func setDestination(position):
	_curPath = _navigationManager.get_simple_path(translation, position)
	_isMoving = true
	_curIndex = 0
	sleeping = false # Make sure enemy is waken up !
	pass

func battleEnded():
	_isInBattle = false
	pass

func damagePlayer():
	getPlayer().takeDamage(_damage)
	pass

func attackFinished():
	emit_signal("onTurnFinished")
	pass
	
func startRotationTween(var toTargetNormalized):
	var targetAngle = -Vector2(0, 1).angle_to(toTargetNormalized)
	var angleDiff = abs(abs(_currentAngle) - abs(targetAngle))
	
	if(angleDiff > 0):
		var time = angleDiff/_rotationSpeed
		_tweener.interpolate_property(self, "rotation", Vector3(0, _currentAngle, 0), Vector3(0, targetAngle, 0), time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		_tweener.interpolate_callback(self, time, "_tweenFinished")
		_tweener.start()
		_currentAngle = targetAngle
		_isTweenActive = true
	pass

func playAttackAnim():
	_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_ATTACK_ID)
	pass

# Private interface
func _ready():
	_setupAnimations()
	set_linear_velocity(Vector3(0, 0, 0))
	pass

func _physics_process(delta):

	var playerPosition = _playerParty.getActivePlayer().get_global_transform().origin
	var enemyPosition = get_global_transform().origin
	var toPlayer =  playerPosition - enemyPosition

	if(isAlive() and !_isInBattle and toPlayer.length_squared() <= _battleRadius*_battleRadius):
		_isInBattle = true
		_isMoving = false
		_playIdleAnimation()
		startRotationTween(Vector2(toPlayer.x, toPlayer.z).normalized())
		_battleManager.initiateBattle(_playerParty, self)
		_battlePosition = enemyPosition

	# Make sure we are really not moving
	if(!_isMoving or _isTakingDamage):
		set_linear_velocity(Vector3(0, 0, 0))
	
	_handleHealthBarPosition()
	pass

func _handleHealthBarPosition():
	
	_healthBar.rect_position = _camera.unproject_position(translation) - (_healthBar.rect_size/2)
	pass

# This function gets called in physics update so its better to modify physics stuff here
func _integrate_forces(state):
	if(_isMoving and !_isTakingDamage):
		if(_curPath.size() > 0 ):
			var target = _curPath[_curIndex]
			var toTargetInSpace = target - get_global_transform().origin
			var toTargetOnPlane = Vector2(toTargetInSpace.x, toTargetInSpace.z)

			if(toTargetOnPlane.length_squared() > 0.25):

				# Move the agent
				var toTargetNormalized = toTargetOnPlane.normalized()
				var velocity = Vector3(toTargetNormalized.x, 0, toTargetNormalized.y) * _moveSpeed
				state.set_linear_velocity(velocity)

				# Rotate in direction of movement
				if(!_isTweenActive):
					startRotationTween(toTargetNormalized)

				# Play Animation
				_playMovingAnimation()

			else:
				# Movement to current point finished
				if(_curIndex < _curPath.size()-1):
					_curIndex += 1
				else:
					_isMoving = false
					_playIdleAnimation()
		else:
			_isMoving = false
			state.set_linear_velocity(Vector3(0, 0, 0))
	pass

func _tweenFinished():
	_isTweenActive = false
	pass

func _playIdleAnimation():
	var currentAnim = _animationTree.transition_node_get_current(GameConsts.ANIM_TRANSITION_NODE)
	if(currentAnim != GameConsts.ANIM_IDLE_ID):
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_IDLE_ID)

		# Make the set animation looping
		var animName = _animationTree.node_get_input_source(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_IDLE_ID)
		var animation = _animationTree.animation_node_get_animation(animName)
		animation.set_loop(true)
	pass

func _playMovingAnimation():
	var currentAnim = _animationTree.transition_node_get_current(GameConsts.ANIM_TRANSITION_NODE)

	# Check if not already playing
	if(currentAnim != GameConsts.ANIM_WALK_ID):
		_animationTree.transition_node_set_current(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_WALK_ID)

		# Make the set animation looping
		var animName = _animationTree.node_get_input_source(GameConsts.ANIM_TRANSITION_NODE, GameConsts.ANIM_WALK_ID)
		var animation = _animationTree.animation_node_get_animation(animName)
		animation.set_loop(true)
	pass

func _setupAnimations():
	_animationTree.set_active(true)
	_playIdleAnimation()
	pass

func _takeDamage(damage):
	_health -= damage
	if(_health < 0):
		_health = 0
	emit_signal("onHealthChanged", _health)
	
	if(_health == 0):
		queue_free()
	pass
	
func _on_Chicken_body_entered(body):
	if(body.name == "fireball"):
		_isTakingDamage = true
		_takeDamage(body.getDamage())
	pass
