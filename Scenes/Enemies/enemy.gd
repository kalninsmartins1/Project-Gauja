extends RigidBody

export var _moveSpeed = 20.0
var _fallowPath = null
var _navigationManager = null
var _player = null
var _curPath = null
var _curIndex = 0

func _ready():
	_fallowPath = get_node("PathFollow")	
	_navigationManager = get_node("../Navigation")
	_player = get_node("../Player")
	_curPath = _navigationManager.get_simple_path(translation, _player.translation)
	pass
	
func _process(delta):
	var target = _curPath[_curIndex]
	var toTarget = target - translation
	var toTargetNormalized = toTarget.normalized()
	
	if(toTarget.length() > 0.5):
		var velocity = Vector3(toTargetNormalized.x, 0, toTargetNormalized.y) * _moveSpeed
		set_axis_velocity(velocity)		
	else:
		if(_curIndex < _curPath.size()-1):
			_curIndex += 1
		set_axis_velocity(Vector3(0,0,0))
	
	pass
