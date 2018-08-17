extends KinematicBody

# Member variables
var _gameConsts = preload("res://Scripts/Utility/GameConsts.gd")
export var _maxSpeed = 10
var _animationTree;

func _isMoving(direction):
	return direction.length_squared() > 0;

func _ready():
	_animationTree = get_node(_gameConsts.ANIMTION_TREE_PLAYER);
	_animationTree.set_active(true)

func _physics_process(delta):	
	var direction = Vector3() # Where does the player intend to walk to
	var forward = Vector3(0, 0, 1)
	
	# Get input
	if (Input.is_action_pressed("move_forward")):
		direction += -forward
	if (Input.is_action_pressed("move_backwards")):
		direction += forward
	if (Input.is_action_pressed("move_left")):
		direction += Vector3(-1, 0, 0)
	if (Input.is_action_pressed("move_right")):
		direction += Vector3(1, 0, 0)
		
	var currentAnim = _animationTree.transition_node_get_current(_gameConsts.ANIM_TRANSITION_NODE)
	
	if(_isMoving(direction)):		
		# Face the movement direction
		var up = Vector3(0, 1, 0)
		look_at(translation - direction, up)
	
		# Move player in direction and collide
		move_and_collide(direction.normalized() * _maxSpeed * delta)
		
		if(currentAnim != _gameConsts.ANIM_WALK_ID):	
			_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_WALK_ID)
	elif(currentAnim != _gameConsts.ANIM_IDLE_ID):
		# Play animation	
		_animationTree.transition_node_set_current(_gameConsts.ANIM_TRANSITION_NODE, _gameConsts.ANIM_IDLE_ID)
	
	
	
	
	
	
	
	
	
	