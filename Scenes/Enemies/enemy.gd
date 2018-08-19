extends RigidBody

# Export vars
export var _moveSpeed = 20.0

# Private vars for this script usage only
var _gameConsts = preload("res://Scripts/Utility/GameConsts.gd")
var _navigationManager = null
var _player = null
var _curPath = null
var _curIndex = 0
var _isMoving = false
var _animationTree = null

# Public Interface

func getPlayer():
	return _player
	pass

func isMoving():
	return _isMoving
	pass

func setDestination(position):	
	_curPath = _navigationManager.get_simple_path(translation, position)
	_isMoving = true
	pass

# Private stuff

func _setupAnimations():
	_animationTree = get_node(_gameConsts.ANIMTION_TREE_PLAYER)
	_animationTree.set_active(true)
	_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_IDLE_ID)	
	
	# Make the set animation looping
	var animName = _animationTree.node_get_input_source(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_IDLE_ID)
	var animation = _animationTree.animation_node_get_animation(animName)
	animation.set_loop(true)
	pass

func _ready():	
	_navigationManager = get_node("../Navigation")
	_player = get_node("../Player")	
	pass
	
func _process(delta):
	
	if(_isMoving):
		if(_curPath.size() > 0 ):
			var target = _curPath[_curIndex]
			var toTarget = target - translation
			var toTargetNormalized = toTarget.normalized()
	
			if(toTarget.length_squared() > 0.25):
				var velocity = Vector3(toTargetNormalized.x, 0, toTargetNormalized.y) * _moveSpeed
				set_axis_velocity(velocity)		
			else:
				if(_curIndex < _curPath.size()-1):
					_curIndex += 1
				else:
					_isMoving = false
				set_axis_velocity(Vector3(0,0,0))
		else:
			_isMoving = false
	pass
