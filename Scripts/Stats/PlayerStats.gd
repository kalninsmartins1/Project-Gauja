extends "res://Scripts/Stats/EntityStats.gd"

export var _mana = 100

var _maxMana = _mana

signal onManaChanged

func hasMana():
	return _mana > 0

func getMana():
	return _mana

func healMana(amount):
	_mana += amount
	_mana = clamp(_mana, 0, _maxMana)
	emit_signal("onManaChanged", _mana, amount)
	pass

func revive():
	.revive()
	var deltaMana = _maxMana - _mana
	_mana = _maxMana
	emit_signal("onManaChanged", _mana, deltaMana)
	pass

func consumeMana(amount):
	var hasEnoughMana = false
	if _mana > amount:
		_mana -= amount
		_mana = clamp(_mana, 0, _maxMana)
		emit_signal("onManaChanged", _mana, -amount)
		hasEnoughMana = true
	return hasEnoughMana
