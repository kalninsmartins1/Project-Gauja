extends Node2D

export var _animationSpeed = 10

onready var _enemy = get_parent()
onready var _tween = get_node("../Tween")
onready var _healthBar = get_node("TextureProgress")

func _ready():	
	_enemy.connect("onHealthChanged", self, "_onHealthChanged")
	pass
	
func _onHealthChanged(newHealthVal, delta):
	
	# Animate the health bar
	Utils.startProgressBarAnimation(_healthBar, _tween, _animationSpeed, newHealthVal)
	pass

