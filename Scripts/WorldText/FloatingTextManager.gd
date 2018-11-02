extends Node

export(PackedScene) var _floatingTextTemplate

onready var _parent = get_parent()
onready var _camera = get_node("/root").get_camera()

func _animateText(text, color):
	var floatingText = _floatingTextTemplate.instance()	
	var parentPosInCameraSpace = _camera.unproject_position(_parent.get_global_transform().origin)
	var textStartPos = parentPosInCameraSpace + Vector2(0, -50)	
	floatingText.startFloating(textStartPos, text, color)
	_camera.add_child(floatingText)	
	pass

func _ready():
	_parent.connect("onHealthChanged", self, "_onFloatingTextRequest")
	_parent.connect("onManaChanged", self, "_onFloatingTextRequest")
	pass

func _onFloatingTextRequest(newValue, delta):
	if delta < 0:
		_animateText(str(delta), Color(1, 0, 0, 1))
	elif delta > 0:
		_animateText("+" + str(delta), Color(0, 1, 0, 1))
	else:
		_animateText("Miss", Color(1, 1, 1, 1))
	pass

