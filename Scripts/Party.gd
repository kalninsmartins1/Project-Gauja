extends Node

var _members = []

func getMembers():
	return _members

func addActiveSpeed(amount):
	for member in _members:
		member.getStats().addActiveSpeed(amount)
	pass

func findMaxBattleSpeedMember():
	var maxSpeed = -INF
	var keyMember = null

	for member in _members:
		var curSpeed = member.getStats().getActiveSpeed()
		if curSpeed > maxSpeed:
			maxSpeed = curSpeed 
			keyMember = member
	return keyMember	
