extends KinematicBody

#var Utils = preload("res://Scripts/Utility/Utils.gd")

# Member variables
const ANIM_IDLE = 0;
const ANIM_RUN = 1;
const ANIM_SWITCH_NAME = "animSwitch";

export var maxSpeed = 10
var animationTree;

func isMoving(direction):
	return direction.magnitude > 0;

func _ready():
	animationTree = get_node("AnimationTreePlayer");
	animationTree.set_active(true)

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
	
	var isMoving = direction.length_squared() > 0
	var currentAnim = animationTree.transition_node_get_current(ANIM_SWITCH_NAME)
	
	if(isMoving):		
		# Face the movement direction
		var up = Vector3(0, 1, 0)
		look_at(translation - direction, up)
	
		# Move player in direction and collide
		move_and_collide(direction.normalized() * maxSpeed * delta)
		if(currentAnim != ANIM_RUN):	
			animationTree.transition_node_set_current(ANIM_SWITCH_NAME, ANIM_RUN)
	elif(currentAnim != ANIM_IDLE):
		# Play animation	
		animationTree.transition_node_set_current(ANIM_SWITCH_NAME, ANIM_IDLE)
	
	
	
	
	
	
	
	
	
	