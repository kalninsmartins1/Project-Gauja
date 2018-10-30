extends Area

# Just set the enter point as respawn point
func _on_SafeArea_body_entered(body):	
	if(body.name.find("player") != -1): # If name contains word "player"
		body.setRespawnPosition(body.translation)
	pass
