extends Area

# Just set the enter point as respawn point
func _on_SafeArea_body_entered(body):
	if(body.name == "Player"):
		body.setRespawnPosition(body.translation)
	pass
