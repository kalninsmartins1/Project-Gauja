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
		var stats = member.getStats()
		var curSpeed = stats.getActiveSpeed()

		if stats.isAlive() and curSpeed > maxSpeed:
			maxSpeed = curSpeed
			keyMember = member
	return keyMember
