extends Spatial

onready var _animationTree = get_node("AnimationTreePlayer")
onready var _physicsBody = get_node("KinematicBody") 
onready var _playerParty = get_node("../PlayerParty")

export(Array, String) var _dialog
export var _interactDistance = 4

func _ready():
	Utils.setAnimationLooping(_animationTree, GameConsts.ANIM_IDLE_ID)
	_physicsBody.connect("input_event", self, "_onMouseEvent")
	pass

func _onMouseEvent(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		var activePlayer = _playerParty.getActivePlayer()
		var toPlayer = activePlayer.get_global_transform().origin - get_global_transform().origin 
		if toPlayer.length_squared() < _interactDistance * _interactDistance:
			_playerParty.startDialog(_dialog)
	pass 
