extends Camera


export var distance = 10
export var height = 10
var player;

func _ready():
	player = get_node("../Player")	
	pass

func _process(delta):	
	var playerPos = player.translation
	var targetPosition = Vector3(playerPos.x, playerPos.y + height, playerPos.z + distance)
	
	translation = translation.linear_interpolate(targetPosition, 0.1)
	pass
