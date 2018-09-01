extends RigidBody

# Export vars
export var _moveSpeed = 20.0
export var _rotationSpeed = 20.0
export var _activeRadius = 100.0

# Private vars for this script usage only
var _gameConsts = preload("res://Scripts/Utility/GameConsts.gd")
var _navigationManager = null
var _player = null
var _tweener = null
var _curPath = null
var _curIndex = 0
var _isMoving = false
var _animationTree = null
var _currentAngle = 0
var _isTweenActive = false

# Public Interface

func getPlayer():
	return _player
	pass
	
func getActiveRadius():
	return _activeRadius
	pass

func isMoving():
	return _isMoving
	pass

func setDestination(position):	
	_curPath = _navigationManager.get_simple_path(translation, position)
	_isMoving = true
	_curIndex = 0
	pass

# Private stuff
func _ready():
	_navigationManager = get_node("../Navigation")
	_player = get_node("../Player")	
	_tweener = get_node("Tween")
	_setupAnimations()
	set_linear_velocity(Vector3(0, 0, 0))
	pass

# This function gets called in physics update so its better to modify physics stuff here
func _integrate_forces(state):
	if(_isMoving):
		if(_curPath.size() > 0 ):
			var target = _curPath[_curIndex]
			var toTargetInSpace = target - translation
			var toTargetOnPlane = Vector2(toTargetInSpace.x, toTargetInSpace.z)
			
			if(toTargetOnPlane.length_squared() > 0.25):
				
				# Move the agent
				var toTargetNormalized = toTargetOnPlane.normalized()
				var velocity = Vector3(toTargetNormalized.x, 0, toTargetNormalized.y) * _moveSpeed
				state.set_linear_velocity(velocity)
				
				# Rotate in direction of movement
				if(!_isTweenActive):
					_setupRotationTween(toTargetNormalized)
				
				# Play Animation
				_playMovingAnimation()
				
			else:
				# Movement to current point finished
				if(_curIndex < _curPath.size()-1):
					_curIndex += 1
				else:
					_isMoving = false
					_playIdleAnimation()
					state.set_linear_velocity(Vector3(0, 0, 0))
		else:
			_isMoving = false
	pass
	
func _setupRotationTween(var toTargetNormalized):
	
	var targetAngle = -Vector2(0, 1).angle_to(toTargetNormalized)
	var time = abs(abs(_currentAngle) - abs(targetAngle))/_rotationSpeed
	_tweener.interpolate_property(self, "rotation", Vector3(0, _currentAngle, 0), Vector3(0, targetAngle, 0), time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tweener.interpolate_callback(self, time, "_tweenFinished")
	_tweener.start()
	_currentAngle = targetAngle
	_isTweenActive = true
	pass
	
func _tweenFinished():
	_isTweenActive = false
	pass
	
func _playIdleAnimation():
	var currentAnim = _animationTree.transition_node_get_current(_gameConsts.ANIM_TRANSITION_NODE)
	if(currentAnim != _gameConsts.ANIM_IDLE_ID):
		_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_IDLE_ID)	
		
		# Make the set animation looping
		var animName = _animationTree.node_get_input_source(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_IDLE_ID)
		var animation = _animationTree.animation_node_get_animation(animName)
		animation.set_loop(true)
	pass
	
func _playMovingAnimation():
	var currentAnim = _animationTree.transition_node_get_current(_gameConsts.ANIM_TRANSITION_NODE)
	
	# Check if not already playing
	if(currentAnim != _gameConsts.ANIM_WALK_ID):
		_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_WALK_ID)	
		
		# Make the set animation looping
		var animName = _animationTree.node_get_input_source(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_WALK_ID)
		var animation = _animationTree.animation_node_get_animation(animName)
		animation.set_loop(true)
	pass

func _setupAnimations():
	_animationTree = get_node(_gameConsts.ANIMTION_TREE_PLAYER)
	_animationTree.set_active(true)
	_playIdleAnimation()
	pass
