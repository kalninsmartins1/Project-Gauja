extends Camera


export var distance = 10
export var height = 10

onready var playerParty = get_node("../PlayerParty")

func _process(delta):	
	var playerPos = playerParty.getActivePlayer().get_global_transform().origin
	var targetPosition = Vector3(playerPos.x, playerPos.y + height, playerPos.z + distance)
	
	translation = translation.linear_interpolate(targetPosition, 0.1)
	pass
