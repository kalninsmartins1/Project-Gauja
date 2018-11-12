extends Node

export var _maxHealth = 100
export var _speed = 10

var _health = 0
var _activeSpeed = 0

signal onHealthChanged

func getActiveSpeed():
	return _activeSpeed

func isAlive():
	return _health > 0

func getHealth():
	return _health

func resetActiveSpeed():
	_activeSpeed = _speed
	pass

func addActiveSpeed(amount):
	_activeSpeed += amount
	_activeSpeed = clamp(_activeSpeed, 0, GameConsts.MAX_BATTLE_SPEED)
	pass

func healHealth(amount):
	_health += amount
	_health = clamp(_health, 0, _maxHealth)
	emit_signal("onHealthChanged", _health, amount)
	pass

func takeDamage(damage):
	healHealth(-damage) # Taking damage is same as healing negative amount	
	pass

func revive():
	healHealth(_maxHealth)
	pass
	
func _ready():
	_health = _maxHealth
	_activeSpeed = _speed
	pass
