extends Spatial

onready var _animationTree = get_node("AnimationTreePlayer")
onready var _physicsBody = get_node("KinematicBody") 

func _ready():
	Utils.setAnimationLooping(_animationTree, GameConsts.ANIM_IDLE_ID)
	_physicsBody.connect("input_event", self, "_onMouseEvent")
	pass

func _onMouseEvent(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		print("Stellar !")
	pass 