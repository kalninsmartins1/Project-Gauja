extends Node

export var _health = 100
export var _speed = 10

var _maxHealth = _health

signal onHealthChanged

func isAlive():
	return _health > 0

func getHealth():
	return _health

func getSpeed():
	return _speed

func healHealth(amount):
	_health += amount
	_health = clamp(_health, 0, _maxHealth)
	emit_signal("onHealthChanged", _health, amount)
	pass

func takeDamage(damage):
	_health -= damage
	clamp(_health, 0, _maxHealth)	
	emit_signal("onHealthChanged", _health, -damage)
	pass

func revive():
	var deltaHealth = _maxHealth - _health
	_health = _maxHealth
	emit_signal("onHealthChanged", _health, deltaHealth)
	pass
